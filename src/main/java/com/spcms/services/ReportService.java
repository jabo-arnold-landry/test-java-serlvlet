package com.spcms.services;

import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.MonitoringLog;
import com.spcms.models.Incident;
import com.spcms.repositories.*;
import com.spcms.util.ReportCalculationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Report Service.
 * YES 
 * Generates Daily Load Averages, Downtime Trends, MTTR (Mean Time To Repair),
 * and MTBF (Mean Time Between Failures) as required for Shift Reports
 * and the Manager Executive Summary Dashboard.
 */
@Service
@Transactional
public class ReportService {

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

    // ==================== Daily Consolidated Report ====================

    /**
     * Generate or retrieve the daily consolidated report for a given date.
     * This auto-calculates MTTR, MTBF, average load, temperature, etc.
     */
    public DailyConsolidatedReport generateDailyReport(LocalDate date) {
        // Check if report already exists
        Optional<DailyConsolidatedReport> existing = dailyReportRepository.findByReportDate(date);
        if (existing.isPresent()) {
            return existing.get();
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

        // === Build report ===
        DailyConsolidatedReport report = DailyConsolidatedReport.builder()
                .reportDate(date)
                .avgDailyLoad(avgDailyLoad)
                .totalUpsAlarms(totalAlarms)
                .avgRoomTemperature(avgRoomTemp)
                .highestTempRecorded(highestTemp)
                .totalIncidents(totalIncidents)
                .totalDowntimeMin(downtimeMin)
                .mttrMinutes(mttr)
                .mtbfHours(mtbf)
                .totalVisitors(totalVisitors)
                .build();

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
}
