package com.spcms.services;

import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.MonitoringLog;
import com.spcms.models.Incident;
import com.spcms.models.SlaCheckResult;
import com.spcms.models.SlaComplianceSummary;
import com.spcms.repositories.*;
import com.spcms.util.ReportCalculationUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Report Service.
 * 
 * Generates Daily Load Averages, Downtime Trends, MTTR (Mean Time To Repair),
 * and MTBF (Mean Time Between Failures) as required for Shift Reports
 * and the Manager Executive Summary Dashboard.
 */
@Service
@Transactional
public class ReportService {

        @Value("${spcms.sla.availability.target-percent:99.90}")
        private BigDecimal availabilityTargetPercent;

        @Value("${spcms.sla.temperature.max-c:28}")
        private BigDecimal temperatureSlaMaxC;

        @Value("${spcms.sla.downtime.monthly-max-minutes:60}")
        private int monthlyDowntimeSlaMinutes;

        @Value("${spcms.sla.response.max-minutes:15}")
        private int responseSlaMinutes;

    @Autowired
    private DailyConsolidatedReportRepository dailyReportRepository;

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

    @Autowired
    private IncidentRepository incidentRepository;

    @Autowired
    private ShiftReportRepository shiftReportRepository;

    @Autowired
    private CoolingAlarmLogRepository coolingAlarmLogRepository;

    @Autowired
    private VisitorCheckInOutRepository visitorCheckInOutRepository;

        @Autowired
        private UpsMaintenanceRepository upsMaintenanceRepository;

        @Autowired
        private CoolingMaintenanceRepository coolingMaintenanceRepository;

    // ==================== Daily Consolidated Report ====================

    /**
     * Generate or retrieve the daily consolidated report for a given date.
     * This auto-calculates MTTR, MTBF, average load, temperature, etc.
     */
    public DailyConsolidatedReport generateDailyReport(LocalDate date) {
        return generateDailyReport(date, false);
    }

    /**
         * Generate daily report. If force is true, the existing report is recalculated and updated.
     */
    public DailyConsolidatedReport generateDailyReport(LocalDate date, boolean force) {
                // Check if report already exists.
        Optional<DailyConsolidatedReport> existing = dailyReportRepository.findByReportDate(date);
        if (existing.isPresent()) {
                        if (!force) {
                return existing.get();
            }
        }

        LocalDateTime dayStart = date.atStartOfDay();
        LocalDateTime dayEnd = date.atTime(LocalTime.MAX);

        // === Calculate UPS metrics ===
        List<MonitoringLog> upsLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.UPS, dayStart, dayEnd);
        List<BigDecimal> loadReadings = upsLogs.stream()
                .map(MonitoringLog::getLoadPercentage)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgDailyLoad = ReportCalculationUtil.calculateDailyAverageLoad(loadReadings);

        // === Calculate Cooling metrics ===
        List<MonitoringLog> coolingLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.COOLING, dayStart, dayEnd);
        List<BigDecimal> temperatures = coolingLogs.stream()
                .map(MonitoringLog::getTemperature)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgRoomTemp = ReportCalculationUtil.calculateAverageTemperature(temperatures);
        BigDecimal highestTemp = ReportCalculationUtil.findMax(temperatures);

        // === Calculate Incident metrics ===
        List<Incident> dailyIncidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd);
        int totalIncidents = dailyIncidents.size();
        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(dayStart, dayEnd);
        int downtimeMin = totalDowntime != null ? totalDowntime : 0;

        BigDecimal mttr = ReportCalculationUtil.calculateMTTR(downtimeMin, totalIncidents);
        BigDecimal mtbf = ReportCalculationUtil.calculateMTBF(24.0, downtimeMin, totalIncidents);

        // === Cooling Alarms ===
        int totalAlarms = coolingAlarmLogRepository.findByAlarmTimeBetween(dayStart, dayEnd).size();

        // === Active Visitors ===
        int totalVisitors = visitorCheckInOutRepository.findActiveVisitors().size();

        // === Build or update report ===
        DailyConsolidatedReport report = existing.orElseGet(DailyConsolidatedReport::new);
        report.setReportDate(date);
        report.setAvgDailyLoad(avgDailyLoad);
        report.setTotalUpsAlarms(totalAlarms);
        report.setAvgRoomTemperature(avgRoomTemp);
        report.setHighestTempRecorded(highestTemp);
        report.setTotalIncidents(totalIncidents);
        report.setTotalDowntimeMin(downtimeMin);
        report.setMttrMinutes(mttr);
        report.setMtbfHours(mtbf);
        report.setTotalVisitors(totalVisitors);

        return dailyReportRepository.save(report);
    }

    // ==================== Report Queries ====================

    public Optional<DailyConsolidatedReport> getDailyReport(LocalDate date) {
        return dailyReportRepository.findByReportDate(date);
    }

    public List<DailyConsolidatedReport> getReportsInRange(LocalDate start, LocalDate end) {
        return dailyReportRepository.findByReportDateBetweenOrderByReportDateDesc(start, end);
    }

    // ==================== Downtime Trend ====================

    /**
     * Calculate downtime trend comparing two date ranges.
     */
    public BigDecimal getDowntimeTrend(LocalDate previousStart, LocalDate previousEnd,
                                        LocalDate currentStart, LocalDate currentEnd) {
        Integer prevDowntime = incidentRepository.sumDowntimeMinutes(
                previousStart.atStartOfDay(), previousEnd.atTime(LocalTime.MAX));
        Integer currDowntime = incidentRepository.sumDowntimeMinutes(
                currentStart.atStartOfDay(), currentEnd.atTime(LocalTime.MAX));

        int prev = prevDowntime != null ? prevDowntime : 0;
        int curr = currDowntime != null ? currDowntime : 0;

        return ReportCalculationUtil.calculateDowntimeTrend(prev, curr);
    }

    // ==================== Load Trend ====================

    /**
     * Get average daily load for a date range (for graphing UPS Load Trend).
     */
    public List<DailyConsolidatedReport> getLoadTrend(LocalDate start, LocalDate end) {
        return dailyReportRepository.findByReportDateBetweenOrderByReportDateDesc(start, end);
    }

    public SlaComplianceSummary buildSlaComplianceSummary(int days) {
        LocalDate today = LocalDate.now();
        LocalDate currentStart = today.minusDays(days - 1L);
        LocalDateTime rangeStart = currentStart.atStartOfDay();
        LocalDateTime rangeEnd = today.atTime(LocalTime.MAX);

        List<DailyConsolidatedReport> reports = getReportsInRange(currentStart, today);
        int totalDowntimeMinutes = reports.stream()
                .map(DailyConsolidatedReport::getTotalDowntimeMin)
                .filter(Objects::nonNull)
                .mapToInt(Integer::intValue)
                .sum();

        BigDecimal totalWindowMinutes = BigDecimal.valueOf(days)
                .multiply(BigDecimal.valueOf(24L * 60L));
        BigDecimal uptimeMinutes = totalWindowMinutes.subtract(BigDecimal.valueOf(totalDowntimeMinutes));
        if (uptimeMinutes.compareTo(BigDecimal.ZERO) < 0) {
            uptimeMinutes = BigDecimal.ZERO;
        }
        BigDecimal availabilityCompliance = uptimeMinutes
                .multiply(BigDecimal.valueOf(100))
                .divide(totalWindowMinutes, 2, RoundingMode.HALF_UP);

        BigDecimal downtimeTrend = getDowntimeTrend(
                today.minusDays(days * 2L), today.minusDays(days),
                currentStart, today);

        BigDecimal allowedDowntimeMinutes = BigDecimal.valueOf(monthlyDowntimeSlaMinutes)
                .multiply(BigDecimal.valueOf(days))
                .divide(BigDecimal.valueOf(30), 2, RoundingMode.HALF_UP);
        boolean downtimeCompliant = BigDecimal.valueOf(totalDowntimeMinutes).compareTo(allowedDowntimeMinutes) <= 0;

        List<MonitoringLog> logs = monitoringLogRepository.findByReadingTimeBetweenOrderByReadingTimeDesc(rangeStart, rangeEnd);
        List<BigDecimal> temperatureReadings = logs.stream()
                .flatMap(log -> java.util.stream.Stream.of(log.getTemperature(), log.getSupplyAirTemp(), log.getReturnAirTemp()))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        BigDecimal maxTemperature = ReportCalculationUtil.findMax(temperatureReadings).setScale(2, RoundingMode.HALF_UP);
        long temperatureViolations = temperatureReadings.stream()
                .filter(temp -> temp.compareTo(temperatureSlaMaxC) > 0)
                .count();
        boolean temperatureCompliant = temperatureViolations == 0;

        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(rangeStart, rangeEnd);
        LocalDateTime now = LocalDateTime.now();
        long responseViolations = 0;

        for (Incident incident : incidents) {
            if (incident.getCreatedAt() == null) {
                continue;
            }

            if (incident.getAssignedTo() == null && incident.getStatus() == Incident.IncidentStatus.OPEN) {
                long openMinutes = ChronoUnit.MINUTES.between(incident.getCreatedAt(), now);
                                if (openMinutes > responseSlaMinutes) {
                    responseViolations++;
                }
                continue;
            }

            if (incident.getUpdatedAt() != null) {
                long responseMinutes = ChronoUnit.MINUTES.between(incident.getCreatedAt(), incident.getUpdatedAt());
                                if (responseMinutes > responseSlaMinutes) {
                    responseViolations++;
                }
            }
        }

        long incidentsEvaluated = incidents.size();
        boolean responseCompliant = responseViolations == 0;
        BigDecimal responseCompliance = incidentsEvaluated == 0
                ? BigDecimal.valueOf(100).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.valueOf((double) (incidentsEvaluated - responseViolations) * 100d / incidentsEvaluated)
                .setScale(2, RoundingMode.HALF_UP);

        int overdueUps = upsMaintenanceRepository.findOverdue(today).size();
        int overdueCooling = coolingMaintenanceRepository.findOverdue(today).size();
        int totalOverdueMaintenance = overdueUps + overdueCooling;
        boolean maintenanceCompliant = totalOverdueMaintenance == 0;

        List<SlaCheckResult> checks = new ArrayList<>();
        checks.add(new SlaCheckResult(
                "Temperature",
                "Maximum temperature",
                "<= " + temperatureSlaMaxC.setScale(2, RoundingMode.HALF_UP) + "C",
                maxTemperature + "C",
                temperatureCompliant,
                temperatureViolations + " violation(s)"
        ));
        checks.add(new SlaCheckResult(
                "Downtime",
                "Maximum allowed downtime",
                allowedDowntimeMinutes + " min / " + days + " day(s)",
                totalDowntimeMinutes + " min",
                downtimeCompliant,
                "Based on monthly SLA of " + monthlyDowntimeSlaMinutes + " min"
        ));
        checks.add(new SlaCheckResult(
                "Response Time",
                "Technician response time",
                "<= " + responseSlaMinutes + " min",
                responseCompliance + "% within SLA",
                responseCompliant,
                responseViolations + " incident(s) exceeded response SLA"
        ));
        checks.add(new SlaCheckResult(
                "Maintenance",
                "Preventive maintenance schedule",
                "No overdue tasks",
                totalOverdueMaintenance + " overdue",
                maintenanceCompliant,
                "UPS overdue: " + overdueUps + ", Cooling overdue: " + overdueCooling
        ));

        long violatedRules = checks.stream().filter(check -> !check.isCompliant()).count();
        long compliantRules = checks.size() - violatedRules;

        return new SlaComplianceSummary(
                days,
                reports.size(),
                availabilityCompliance,
                downtimeTrend,
                totalDowntimeMinutes,
                allowedDowntimeMinutes,
                maxTemperature,
                temperatureReadings.size(),
                temperatureViolations,
                incidentsEvaluated,
                responseViolations,
                responseCompliance,
                totalOverdueMaintenance,
                compliantRules,
                violatedRules,
                                availabilityTargetPercent,
                                temperatureSlaMaxC,
                                responseSlaMinutes,
                                monthlyDowntimeSlaMinutes,
                checks
        );
    }
}
