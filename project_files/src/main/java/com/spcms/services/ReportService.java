package com.spcms.services;

import com.spcms.models.BranchPerformanceReport;
import com.spcms.models.CoolingMaintenance;
import com.spcms.models.CostAnalysisReport;
import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.Incident;
import com.spcms.models.MaintenanceHistoryRecord;
import com.spcms.models.MonitoringLog;
import com.spcms.models.UpsMaintenance;
import com.spcms.models.User;
import com.spcms.repositories.BranchPerformanceReportRepository;
import com.spcms.repositories.CoolingAlarmLogRepository;
import com.spcms.repositories.CoolingMaintenanceRepository;
import com.spcms.repositories.CostAnalysisReportRepository;
import com.spcms.repositories.DailyConsolidatedReportRepository;
import com.spcms.repositories.IncidentRepository;
import com.spcms.repositories.MonitoringLogRepository;
import com.spcms.repositories.ShiftReportRepository;
import com.spcms.repositories.UpsMaintenanceRepository;
import com.spcms.repositories.UserRepository;
import com.spcms.repositories.VisitorCheckInOutRepository;
import com.spcms.util.ReportCalculationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Report Service.
 *
 * Generates Daily Load Averages, Downtime Trends, MTTR (Mean Time To Repair),
 * and MTBF (Mean Time Between Failures) as required for Shift Reports and the
 * Manager Executive Summary Dashboard.
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

    @Autowired
    private BranchPerformanceReportRepository branchPerformanceReportRepository;

    @Autowired
    private CostAnalysisReportRepository costAnalysisReportRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UpsMaintenanceRepository upsMaintenanceRepository;

    @Autowired
    private CoolingMaintenanceRepository coolingMaintenanceRepository;

    // ==================== Daily Consolidated Report ====================
    /**
     * Generate or retrieve the daily consolidated report for a given date.
     */
    public DailyConsolidatedReport generateDailyReport(LocalDate date) {
        Optional<DailyConsolidatedReport> existing = dailyReportRepository.findByReportDate(date);
        if (existing.isPresent()) {
            return existing.get();
        }

        LocalDateTime dayStart = date.atStartOfDay();
        LocalDateTime dayEnd = date.atTime(LocalTime.MAX);

        List<MonitoringLog> upsLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.UPS, dayStart, dayEnd);
        List<BigDecimal> loadReadings = upsLogs.stream()
                .map(MonitoringLog::getLoadPercentage)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgDailyLoad = ReportCalculationUtil.calculateDailyAverageLoad(loadReadings);

        List<MonitoringLog> coolingLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.COOLING, dayStart, dayEnd);
        List<BigDecimal> temperatures = coolingLogs.stream()
                .map(MonitoringLog::getTemperature)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgRoomTemp = ReportCalculationUtil.calculateAverageTemperature(temperatures);
        BigDecimal highestTemp = ReportCalculationUtil.findMax(temperatures);

        List<Incident> dailyIncidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd);
        int totalIncidents = dailyIncidents.size();
        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(dayStart, dayEnd);
        int downtimeMin = totalDowntime != null ? totalDowntime : 0;

        BigDecimal mttr = ReportCalculationUtil.calculateMTTR(downtimeMin, totalIncidents);
        BigDecimal mtbf = ReportCalculationUtil.calculateMTBF(24.0, downtimeMin, totalIncidents);

        int totalAlarms = coolingAlarmLogRepository.findByAlarmTimeBetween(dayStart, dayEnd).size();
        int totalVisitors = visitorCheckInOutRepository.findActiveVisitors().size();

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

    public List<String> getAllBranches() {
        List<String> userBranches = userRepository.findAll().stream()
                .map(User::getBranch)
                .filter(branch -> branch != null && !branch.isBlank())
                .map(String::trim)
                .distinct()
                .sorted()
                .collect(Collectors.toList());

        if (!userBranches.isEmpty()) {
            return userBranches;
        }

        List<String> reportBranches = branchPerformanceReportRepository.findAll().stream()
                .map(BranchPerformanceReport::getBranch)
                .filter(branch -> branch != null && !branch.isBlank())
                .map(String::trim)
                .distinct()
                .sorted()
                .collect(Collectors.toList());

        return reportBranches.isEmpty() ? List.of("Main Data Center") : reportBranches;
    }

    public BranchPerformanceReport generateBranchPerformanceReport(String branch, LocalDate date) {
        LocalDate reportDate = date != null ? date : LocalDate.now();
        String reportBranch = normalizeBranchLabel(branch);
        LocalDateTime dayStart = reportDate.atStartOfDay();
        LocalDateTime dayEnd = reportDate.atTime(LocalTime.MAX);

        List<MonitoringLog> upsLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.UPS, dayStart, dayEnd);
        List<BigDecimal> loadReadings = upsLogs.stream()
                .map(MonitoringLog::getLoadPercentage)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());

        List<MonitoringLog> coolingLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.COOLING, dayStart, dayEnd);
        List<BigDecimal> temperatures = coolingLogs.stream()
                .map(log -> log.getReturnAirTemp() != null ? log.getReturnAirTemp() : log.getTemperature())
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());

        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd);
        long criticalIncidents = incidents.stream()
                .filter(incident -> incident.getSeverity() == Incident.Severity.CRITICAL)
                .count();
        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(dayStart, dayEnd);
        int downtimeMinutes = totalDowntime != null ? totalDowntime : 0;
        BigDecimal mttr = ReportCalculationUtil.calculateMTTR(downtimeMinutes, incidents.size());
        BigDecimal mtbf = ReportCalculationUtil.calculateMTBF(24.0, downtimeMinutes, incidents.size());

        BranchPerformanceReport report = branchPerformanceReportRepository
                .findByBranchAndReportDate(reportBranch, reportDate)
                .orElseGet(() -> BranchPerformanceReport.builder()
                        .branch(reportBranch)
                        .reportDate(reportDate)
                        .build());

        BigDecimal highestTemp = ReportCalculationUtil.findMax(temperatures);
        report.setAvgDailyLoad(ReportCalculationUtil.calculateDailyAverageLoad(loadReadings));
        report.setPeakLoad(ReportCalculationUtil.findMax(loadReadings));
        report.setTotalUpsAlarms(coolingAlarmLogRepository.findByAlarmTimeBetween(dayStart, dayEnd).size());
        report.setAvgRoomTemperature(ReportCalculationUtil.calculateAverageTemperature(temperatures));
        report.setHighestTempRecorded(highestTemp);
        report.setCoolingFailure(highestTemp != null && highestTemp.compareTo(new BigDecimal("28")) > 0);
        report.setTotalIncidents(incidents.size());
        report.setCriticalIncidents((int) criticalIncidents);
        report.setTotalDowntimeMin(downtimeMinutes);
        report.setMttrMinutes(mttr);
        report.setMtbfHours(mtbf);
        report.setTotalVisitors(visitorCheckInOutRepository.findActiveVisitors().size());
        report.setOverstayedVisitors(0);
        report.setUserCount(countUsersForBranch(reportBranch));

        return branchPerformanceReportRepository.save(report);
    }

    public Optional<BranchPerformanceReport> getBranchPerformanceReport(String branch, LocalDate date) {
        return branchPerformanceReportRepository.findByBranchAndReportDate(normalizeBranchLabel(branch), date);
    }

    public List<BranchPerformanceReport> getBranchPerformanceReportsInRange(String branch, LocalDate start, LocalDate end) {
        return branchPerformanceReportRepository.findByBranchAndReportDateBetweenOrderByReportDateDesc(
                normalizeBranchLabel(branch), start, end);
    }

    public List<BranchPerformanceReport> getBranchPerformanceReportsByDate(LocalDate date) {
        return branchPerformanceReportRepository.findByReportDate(date);
    }

    public CostAnalysisReport generateCostAnalysisReport(LocalDate date, String branch) {
        LocalDate reportDate = date != null ? date : LocalDate.now();
        String normalizedBranch = normalizeOptionalBranch(branch);
        LocalDateTime dayStart = reportDate.atStartOfDay();
        LocalDateTime dayEnd = reportDate.atTime(LocalTime.MAX);

        List<UpsMaintenance> upsMaintenance = upsMaintenanceRepository.findAll().stream()
                .filter(record -> reportDate.equals(record.getMaintenanceDate()))
                .collect(Collectors.toList());
        List<CoolingMaintenance> coolingMaintenance = coolingMaintenanceRepository.findAll().stream()
                .filter(record -> reportDate.equals(record.getMaintenanceDate()))
                .collect(Collectors.toList());
        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd);

        BigDecimal upsMaintenanceCost = sumMaintenanceCosts(upsMaintenance.stream()
                .map(UpsMaintenance::getMaintenanceCost)
                .collect(Collectors.toList()));
        BigDecimal coolingMaintenanceCost = sumMaintenanceCosts(coolingMaintenance.stream()
                .map(CoolingMaintenance::getMaintenanceCost)
                .collect(Collectors.toList()));
        BigDecimal preventiveMaintenanceCost = sumMaintenanceCosts(upsMaintenance.stream()
                .filter(record -> record.getMaintenanceType() == UpsMaintenance.MaintenanceType.PREVENTIVE)
                .map(UpsMaintenance::getMaintenanceCost)
                .collect(Collectors.toList()))
                .add(sumMaintenanceCosts(coolingMaintenance.stream()
                        .filter(record -> record.getMaintenanceType() == CoolingMaintenance.MaintenanceType.PREVENTIVE)
                        .map(CoolingMaintenance::getMaintenanceCost)
                        .collect(Collectors.toList())));
        BigDecimal correctiveMaintenanceCost = sumMaintenanceCosts(upsMaintenance.stream()
                .filter(record -> record.getMaintenanceType() == UpsMaintenance.MaintenanceType.CORRECTIVE)
                .map(UpsMaintenance::getMaintenanceCost)
                .collect(Collectors.toList()))
                .add(sumMaintenanceCosts(coolingMaintenance.stream()
                        .filter(record -> record.getMaintenanceType() == CoolingMaintenance.MaintenanceType.CORRECTIVE)
                        .map(CoolingMaintenance::getMaintenanceCost)
                        .collect(Collectors.toList())));

        BigDecimal totalRepairCost = sumMaintenanceCosts(incidents.stream()
                .map(Incident::getRepairCost)
                .collect(Collectors.toList()));
        BigDecimal criticalIncidentCost = sumMaintenanceCosts(incidents.stream()
                .filter(incident -> incident.getSeverity() == Incident.Severity.CRITICAL)
                .map(Incident::getRepairCost)
                .collect(Collectors.toList()));
        int totalDowntimeMinutes = incidents.stream()
                .map(Incident::getDowntimeMinutes)
                .filter(java.util.Objects::nonNull)
                .mapToInt(Integer::intValue)
                .sum();
        BigDecimal costPerHourLoss = new BigDecimal("500");
        BigDecimal totalDowntimeCost = costPerHourLoss
                .multiply(BigDecimal.valueOf(totalDowntimeMinutes))
                .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        BigDecimal totalMaintenanceCost = upsMaintenanceCost.add(coolingMaintenanceCost);
        BigDecimal totalOperationalCost = totalMaintenanceCost.add(totalRepairCost).add(totalDowntimeCost);
        int maintenanceEvents = upsMaintenance.size() + coolingMaintenance.size();
        BigDecimal maintenanceCostPerHour = totalMaintenanceCost.divide(BigDecimal.valueOf(24), 2, RoundingMode.HALF_UP);

        Optional<CostAnalysisReport> existing = normalizedBranch == null
                ? costAnalysisReportRepository.findByReportDate(reportDate)
                : costAnalysisReportRepository.findByBranchAndReportDate(normalizedBranch, reportDate);

        CostAnalysisReport report = existing.orElseGet(() -> CostAnalysisReport.builder()
                .reportDate(reportDate)
                .branch(normalizedBranch)
                .build());

        report.setBranch(normalizedBranch);
        report.setTotalMaintenanceCost(totalMaintenanceCost);
        report.setUpsMaintenanceCost(upsMaintenanceCost);
        report.setCoolingMaintenanceCost(coolingMaintenanceCost);
        report.setPreventiveMaintenanceCost(preventiveMaintenanceCost);
        report.setCorrectiveMaintenanceCost(correctiveMaintenanceCost);
        report.setTotalRepairCost(totalRepairCost);
        report.setCriticalIncidentCost(criticalIncidentCost);
        report.setTotalDowntimeMinutes(totalDowntimeMinutes);
        report.setCostPerHourLoss(costPerHourLoss);
        report.setTotalDowntimeCost(totalDowntimeCost);
        report.setTotalMaintenanceCostAll(totalMaintenanceCost);
        report.setTotalOperationalCost(totalOperationalCost);
        report.setMaintenanceCostPerHour(maintenanceCostPerHour);
        report.setTotalIncidents(incidents.size());
        report.setMaintenanceEvents(maintenanceEvents);

        return costAnalysisReportRepository.save(report);
    }

    public Optional<CostAnalysisReport> getCostAnalysisReport(String branch, LocalDate date) {
        String normalizedBranch = normalizeOptionalBranch(branch);
        return normalizedBranch == null
                ? costAnalysisReportRepository.findByReportDate(date)
                : costAnalysisReportRepository.findByBranchAndReportDate(normalizedBranch, date);
    }

    public List<CostAnalysisReport> getCostAnalysisReportsInRange(LocalDate start, LocalDate end) {
        return costAnalysisReportRepository.findByReportDateBetweenOrderByReportDateDesc(start, end);
    }

    public List<CostAnalysisReport> getCostAnalysisReportsInRange(String branch, LocalDate start, LocalDate end) {
        String normalizedBranch = normalizeOptionalBranch(branch);
        return normalizedBranch == null
                ? getCostAnalysisReportsInRange(start, end)
                : costAnalysisReportRepository.findByBranchAndReportDateBetweenOrderByReportDateDesc(
                        normalizedBranch, start, end);
    }

    // ==================== Downtime Trend ====================

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

    public List<DailyConsolidatedReport> getLoadTrend(LocalDate start, LocalDate end) {
        return dailyReportRepository.findByReportDateBetweenOrderByReportDateDesc(start, end);
    }

    // ==================== Equipment Health Report ====================

    public Map<String, Object> generateEquipmentHealthReport(LocalDate start, LocalDate end) {
        Map<String, Object> report = new HashMap<>();
        LocalDateTime startTime = start.atStartOfDay();
        LocalDateTime endTime = end.atTime(LocalTime.MAX);

        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(startTime, endTime);
        long criticalIncidents = incidents.stream()
                .filter(i -> i.getSeverity() == Incident.Severity.CRITICAL)
                .count();
        long resolvedIncidents = incidents.stream()
                .filter(i -> i.getStatus() == Incident.IncidentStatus.RESOLVED || i.getStatus() == Incident.IncidentStatus.CLOSED)
                .count();

        BigDecimal avgDowntime = incidents.isEmpty()
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(incidents.stream()
                        .mapToLong(i -> i.getDowntimeMinutes() != null ? i.getDowntimeMinutes() : 0)
                        .sum())
                        .divide(BigDecimal.valueOf(incidents.size()), 2, RoundingMode.HALF_UP);

        report.put("dateRange", start + " to " + end);
        report.put("totalIncidents", incidents.size());
        report.put("criticalIncidents", criticalIncidents);
        report.put("resolvedIncidents", resolvedIncidents);
        report.put("avgDowntimeMinutes", avgDowntime);
        report.put("generatedAt", LocalDateTime.now());

        return report;
    }

    // ==================== Cost of Maintenance Report ====================

    public Map<String, Object> generateCostOfMaintenanceReport(LocalDate start, LocalDate end) {
        Map<String, Object> report = new HashMap<>();
        LocalDateTime startTime = start.atStartOfDay();
        LocalDateTime endTime = end.atTime(LocalTime.MAX);

        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(startTime, endTime);

        BigDecimal laborCost = BigDecimal.valueOf(incidents.size() * 100L);
        BigDecimal downtimeCost = BigDecimal.ZERO;
        BigDecimal partsCost = BigDecimal.valueOf(incidents.size() * 250L);

        for (Incident incident : incidents) {
            if (incident.getDowntimeMinutes() != null) {
                BigDecimal downtimeHours = BigDecimal.valueOf(incident.getDowntimeMinutes())
                        .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
                downtimeCost = downtimeCost.add(downtimeHours.multiply(BigDecimal.valueOf(500)));
            }
        }

        BigDecimal totalCost = laborCost.add(downtimeCost).add(partsCost);
        BigDecimal avgCostPerIncident = incidents.isEmpty()
                ? BigDecimal.ZERO
                : totalCost.divide(BigDecimal.valueOf(incidents.size()), 2, RoundingMode.HALF_UP);

        report.put("dateRange", start + " to " + end);
        report.put("laborCost", laborCost);
        report.put("downtimeCost", downtimeCost);
        report.put("partsCost", partsCost);
        report.put("totalCost", totalCost);
        report.put("incidentCount", incidents.size());
        report.put("avgCostPerIncident", avgCostPerIncident);
        report.put("generatedAt", LocalDateTime.now());

        return report;
    }

    // ==================== Downtime Analysis Report ====================

    public Map<String, Object> generateDowntimeAnalysisReport(LocalDate start, LocalDate end) {
        Map<String, Object> report = new HashMap<>();
        LocalDateTime startTime = start.atStartOfDay();
        LocalDateTime endTime = end.atTime(LocalTime.MAX);

        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(startTime, endTime);

        long totalDowntimeMinutes = incidents.stream()
                .mapToLong(i -> i.getDowntimeMinutes() != null ? i.getDowntimeMinutes() : 0)
                .sum();

        BigDecimal avgDowntime = incidents.isEmpty()
                ? BigDecimal.ZERO
                : BigDecimal.valueOf(totalDowntimeMinutes).divide(BigDecimal.valueOf(incidents.size()), 2, RoundingMode.HALF_UP);

        long criticalCount = incidents.stream()
                .filter(i -> i.getSeverity() == Incident.Severity.CRITICAL)
                .count();

        report.put("dateRange", start + " to " + end);
        report.put("totalDowntimeMinutes", totalDowntimeMinutes);
        report.put("totalDowntimeHours", BigDecimal.valueOf(totalDowntimeMinutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP));
        report.put("incidentCount", incidents.size());
        report.put("avgDowntimePerIncident", avgDowntime);
        report.put("criticalIncidents", criticalCount);
        report.put("generatedAt", LocalDateTime.now());

        return report;
    }

    // ==================== Monthly/Quarterly Reports ====================

    public Map<String, Object> generateMonthlyQuarterlyReports(String period) {
        Map<String, Object> report = new HashMap<>();

        LocalDate today = LocalDate.now();
        LocalDate periodStart;
        String periodLabel;

        if ("QUARTER".equalsIgnoreCase(period)) {
            int quarter = (today.getMonthValue() - 1) / 3 + 1;
            periodStart = today.withMonth((quarter - 1) * 3 + 1).withDayOfMonth(1);
            periodLabel = "Q" + quarter + " " + today.getYear();
        } else {
            periodStart = today.withDayOfMonth(1);
            periodLabel = today.getMonth() + " " + today.getYear();
        }

        LocalDateTime startTime = periodStart.atStartOfDay();
        LocalDateTime endTime = today.atTime(LocalTime.MAX);

        List<DailyConsolidatedReport> dailyReports = dailyReportRepository
                .findByReportDateBetweenOrderByReportDateDesc(periodStart, today);
        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(startTime, endTime);

        long totalDowntime = incidents.stream()
                .mapToLong(i -> i.getDowntimeMinutes() != null ? i.getDowntimeMinutes() : 0)
                .sum();

        report.put("period", periodLabel);
        report.put("daysInPeriod", dailyReports.size());
        report.put("incidentCount", incidents.size());
        report.put("totalDowntimeMinutes", totalDowntime);
        report.put("generatedAt", LocalDateTime.now());

        return report;
    }

    private int countUsersForBranch(String branch) {
        if (branch == null || branch.isBlank()) {
            return (int) userRepository.count();
        }
        return userRepository.findByBranch(branch).size();
    }

    private String normalizeBranchLabel(String branch) {
        String normalized = normalizeOptionalBranch(branch);
        if (normalized != null) {
            return normalized;
        }
        List<String> branches = getAllBranches();
        return branches.isEmpty() ? "Main Data Center" : branches.get(0);
    }

    private String normalizeOptionalBranch(String branch) {
        if (branch == null || branch.isBlank()) {
            return null;
        }
        return branch.trim();
    }

    private BigDecimal sumMaintenanceCosts(List<BigDecimal> values) {
        return values.stream()
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    // ==================== Maintenance History Report ====================

        public Map<String, Object> generateMaintenanceHistoryReport(LocalDate start, LocalDate end) {
                return generateMaintenanceHistoryReport(start, end, null, "ALL", null, "ALL", "ALL", null, "newest");
        }

        public Map<String, Object> generateMaintenanceHistoryReport(LocalDate start,
                        LocalDate end,
                        String assetId,
                        String equipmentType,
                        String technicianName,
                        String maintenanceCategory,
                        String status,
                        String keyword,
                        String sortOrder) {

                LocalDate fromDate = start;
                LocalDate toDate = end;
                if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
                        LocalDate temp = fromDate;
                        fromDate = toDate;
                        toDate = temp;
                }

                String dateRangeLabel = "All records";
                if (fromDate != null && toDate != null) {
                        dateRangeLabel = fromDate + " to " + toDate;
                } else if (fromDate != null) {
                        dateRangeLabel = "From " + fromDate;
                } else if (toDate != null) {
                        dateRangeLabel = "Up to " + toDate;
                }

                String normalizedEquipmentType = normalizeFilter(equipmentType, "ALL");
                String normalizedCategory = normalizeFilter(maintenanceCategory, "ALL");
                String normalizedStatus = normalizeFilter(status, "ALL");
                String normalizedSort = normalizeSortOrder(sortOrder);

                List<MaintenanceHistoryRecord> records = getMaintenanceHistoryRecordsInternal(
                                fromDate,
                                toDate,
                                assetId,
                                normalizedEquipmentType,
                                technicianName,
                                normalizedCategory,
                                normalizedStatus,
                                keyword,
                                normalizedSort);

                long preventiveCount = records.stream()
                                .filter(r -> "PREVENTIVE".equalsIgnoreCase(r.getMaintenanceType()))
                                .count();
                long correctiveCount = records.stream()
                                .filter(r -> "CORRECTIVE".equalsIgnoreCase(r.getMaintenanceType()))
                                .count();
                long overdueCount = records.stream()
                                .filter(r -> "OVERDUE".equalsIgnoreCase(r.getStatus()))
                                .count();
                long scheduledCount = records.stream()
                                .filter(r -> "SCHEDULED".equalsIgnoreCase(r.getStatus()))
                                .count();
                long completedCount = records.stream()
                                .filter(r -> "COMPLETED".equalsIgnoreCase(r.getStatus()))
                                .count();
                long upsRelated = records.stream()
                                .filter(r -> "UPS".equalsIgnoreCase(r.getEquipmentType()))
                                .count();
                long coolingRelated = records.stream()
                                .filter(r -> "COOLING".equalsIgnoreCase(r.getEquipmentType()))
                                .count();

        Map<String, Object> report = new HashMap<>();
                report.put("dateRange", dateRangeLabel);
                report.put("fromDate", fromDate);
                report.put("toDate", toDate);
                report.put("totalMaintenanceRecords", records.size());
                report.put("preventiveRecords", preventiveCount);
                report.put("correctiveRecords", correctiveCount);
                report.put("overdueRecords", overdueCount);
                report.put("scheduledRecords", scheduledCount);
                report.put("completedRecords", completedCount);
        report.put("upsRelated", upsRelated);
        report.put("coolingRelated", coolingRelated);
                report.put("records", records);
                report.put("assetId", assetId != null ? assetId : "");
                report.put("equipmentType", normalizedEquipmentType);
                report.put("technicianName", technicianName != null ? technicianName : "");
                report.put("maintenanceCategory", normalizedCategory);
                report.put("status", normalizedStatus);
                report.put("keyword", keyword != null ? keyword : "");
                report.put("sort", normalizedSort);
        report.put("generatedAt", LocalDateTime.now());

        return report;
    }

        @SuppressWarnings("unchecked")
        public List<MaintenanceHistoryRecord> getMaintenanceHistoryRecords(LocalDate start,
                        LocalDate end,
                        String assetId,
                        String equipmentType,
                        String technicianName,
                        String maintenanceCategory,
                        String status,
                        String keyword,
                        String sortOrder) {
                return (List<MaintenanceHistoryRecord>) generateMaintenanceHistoryReport(start,
                                end,
                                assetId,
                                equipmentType,
                                technicianName,
                                maintenanceCategory,
                                status,
                                keyword,
                                sortOrder).get("records");
        }

        public Optional<MaintenanceHistoryRecord> getMaintenanceHistoryDetail(String equipmentType, Long maintenanceId) {
                if (equipmentType == null || maintenanceId == null) {
                        return Optional.empty();
                }

                String normalizedType = equipmentType.trim().toUpperCase(Locale.ROOT);
                if ("UPS".equals(normalizedType)) {
                        return upsMaintenanceRepository.findById(maintenanceId).map(this::mapUpsMaintenanceRecord);
                }

                if ("COOLING".equals(normalizedType)) {
                        return coolingMaintenanceRepository.findById(maintenanceId).map(this::mapCoolingMaintenanceRecord);
                }

                return Optional.empty();
        }

        public String buildMaintenanceHistoryCsv(List<MaintenanceHistoryRecord> records) {
                StringBuilder csv = new StringBuilder();
                csv.append("report_id,equipment_type,equipment_name,asset_id,maintenance_date,maintenance_type,technician_name,work_performed,status,remarks,next_scheduled_maintenance,vendor");
                csv.append("\n");

                for (MaintenanceHistoryRecord record : records) {
                        csv.append(escapeCsv(record.getReportId() != null ? record.getReportId().toString() : ""))
                                        .append(',')
                                        .append(escapeCsv(record.getEquipmentType()))
                                        .append(',')
                                        .append(escapeCsv(record.getEquipmentName()))
                                        .append(',')
                                        .append(escapeCsv(record.getAssetId()))
                                        .append(',')
                                        .append(escapeCsv(record.getMaintenanceDate() != null ? record.getMaintenanceDate().toString() : ""))
                                        .append(',')
                                        .append(escapeCsv(record.getMaintenanceType()))
                                        .append(',')
                                        .append(escapeCsv(record.getTechnicianName()))
                                        .append(',')
                                        .append(escapeCsv(record.getWorkPerformed()))
                                        .append(',')
                                        .append(escapeCsv(record.getStatus()))
                                        .append(',')
                                        .append(escapeCsv(record.getRemarks()))
                                        .append(',')
                                        .append(escapeCsv(record.getNextScheduledMaintenance() != null
                                                        ? record.getNextScheduledMaintenance().toString()
                                                        : ""))
                                        .append(',')
                                        .append(escapeCsv(record.getVendor()))
                                        .append('\n');
                }

                return csv.toString();
        }

        private List<MaintenanceHistoryRecord> getMaintenanceHistoryRecordsInternal(LocalDate fromDate,
                        LocalDate toDate,
                        String assetId,
                        String equipmentType,
                        String technicianName,
                        String maintenanceCategory,
                        String status,
                        String keyword,
                        String sortOrder) {

                List<MaintenanceHistoryRecord> records = new ArrayList<>();

                List<UpsMaintenance> upsRecords = upsMaintenanceRepository.findAll();
                for (UpsMaintenance upsMaintenance : upsRecords) {
                        records.add(mapUpsMaintenanceRecord(upsMaintenance));
                }

                List<CoolingMaintenance> coolingRecords = coolingMaintenanceRepository.findAll();
                for (CoolingMaintenance coolingMaintenance : coolingRecords) {
                        records.add(mapCoolingMaintenanceRecord(coolingMaintenance));
                }

                List<MaintenanceHistoryRecord> filtered = records.stream()
                                .filter(r -> isWithinDateRange(r.getMaintenanceDate(), fromDate, toDate))
                                .filter(r -> matchesExactOrAll(r.getEquipmentType(), equipmentType))
                                .filter(r -> matchesExactOrAll(r.getMaintenanceType(), maintenanceCategory))
                                .filter(r -> matchesExactOrAll(r.getStatus(), status))
                                .filter(r -> containsIgnoreCase(r.getAssetId(), assetId))
                                .filter(r -> containsIgnoreCase(r.getTechnicianName(), technicianName))
                                .filter(r -> matchesKeyword(r, keyword))
                                .collect(Collectors.toList());

                Comparator<MaintenanceHistoryRecord> comparator = Comparator
                                .comparing(MaintenanceHistoryRecord::getMaintenanceDate, Comparator.nullsLast(LocalDate::compareTo))
                                .thenComparing(MaintenanceHistoryRecord::getReportId, Comparator.nullsLast(Long::compareTo));

                if (!"oldest".equalsIgnoreCase(sortOrder)) {
                        comparator = comparator.reversed();
                }

                filtered.sort(comparator);
                return filtered;
        }

        private MaintenanceHistoryRecord mapUpsMaintenanceRecord(UpsMaintenance maintenance) {
                String equipmentName = maintenance.getUps() != null ? maintenance.getUps().getUpsName() : "UPS";
                String assetTag = maintenance.getUps() != null ? maintenance.getUps().getAssetTag() : "N/A";
                LocalDate nextScheduled = maintenance.getNextDueDate();
                String workPerformed = firstNonBlank(
                                maintenance.getSparePartsUsed(),
                                maintenance.getRemarks(),
                                "UPS maintenance activity logged");

                return MaintenanceHistoryRecord.builder()
                                .reportId(maintenance.getMaintenanceId())
                                .equipmentType("UPS")
                                .equipmentId(maintenance.getUps() != null ? maintenance.getUps().getUpsId() : null)
                                .equipmentName(equipmentName)
                                .assetId(assetTag)
                                .maintenanceDate(maintenance.getMaintenanceDate())
                                .maintenanceType(maintenance.getMaintenanceType() != null ? maintenance.getMaintenanceType().name() : "UNKNOWN")
                                .technicianName(firstNonBlank(maintenance.getTechnician(), "Unassigned"))
                                .workPerformed(workPerformed)
                                .description(workPerformed)
                                .status(resolveStatus(maintenance.getMaintenanceDate(), nextScheduled))
                                .remarks(firstNonBlank(maintenance.getRemarks(), "-"))
                                .nextScheduledMaintenance(nextScheduled)
                                .vendor(firstNonBlank(maintenance.getVendor(), "-"))
                                .serviceReportPath(maintenance.getServiceReportPath())
                                .partsOrMaterials(firstNonBlank(maintenance.getSparePartsUsed(), "-"))
                                .build();
        }

        private MaintenanceHistoryRecord mapCoolingMaintenanceRecord(CoolingMaintenance maintenance) {
                String equipmentName = maintenance.getCoolingUnit() != null ? maintenance.getCoolingUnit().getUnitName() : "Cooling Unit";
                String assetTag = maintenance.getCoolingUnit() != null ? maintenance.getCoolingUnit().getAssetTag() : "N/A";
                LocalDate nextScheduled = maintenance.getNextMaintenanceDate();
                String workPerformed = buildCoolingWorkPerformed(maintenance);

                return MaintenanceHistoryRecord.builder()
                                .reportId(maintenance.getMaintenanceId())
                                .equipmentType("COOLING")
                                .equipmentId(maintenance.getCoolingUnit() != null ? maintenance.getCoolingUnit().getCoolingId() : null)
                                .equipmentName(equipmentName)
                                .assetId(assetTag)
                                .maintenanceDate(maintenance.getMaintenanceDate())
                                .maintenanceType(maintenance.getMaintenanceType() != null ? maintenance.getMaintenanceType().name() : "UNKNOWN")
                                .technicianName(firstNonBlank(maintenance.getTechnician(), "Unassigned"))
                                .workPerformed(workPerformed)
                                .description(workPerformed)
                                .status(resolveStatus(maintenance.getMaintenanceDate(), nextScheduled))
                                .remarks(firstNonBlank(maintenance.getRemarks(), "-"))
                                .nextScheduledMaintenance(nextScheduled)
                                .vendor(firstNonBlank(maintenance.getVendor(), "-"))
                                .serviceReportPath(maintenance.getServiceReportPath())
                                .filterCleaningDate(maintenance.getFilterCleaningDate())
                                .gasRefillDate(maintenance.getGasRefillDate())
                                .build();
        }

        private String buildCoolingWorkPerformed(CoolingMaintenance maintenance) {
                List<String> steps = new ArrayList<>();
                if (maintenance.getFilterCleaningDate() != null) {
                        steps.add("Filter cleaning");
                }
                if (maintenance.getGasRefillDate() != null) {
                        steps.add("Gas refill");
                }

                if (!steps.isEmpty()) {
                        return String.join(", ", steps);
                }

                return firstNonBlank(maintenance.getRemarks(), "Cooling maintenance activity logged");
        }

        private String resolveStatus(LocalDate maintenanceDate, LocalDate nextScheduledDate) {
                LocalDate today = LocalDate.now();
                if (maintenanceDate != null && maintenanceDate.isAfter(today)) {
                        return "SCHEDULED";
                }
                if (nextScheduledDate != null && !nextScheduledDate.isAfter(today)) {
                        return "OVERDUE";
                }
                return "COMPLETED";
        }

        private boolean isWithinDateRange(LocalDate date, LocalDate fromDate, LocalDate toDate) {
                if (date == null) {
                        return false;
                }

                boolean afterFrom = fromDate == null || date.isEqual(fromDate) || date.isAfter(fromDate);
                boolean beforeTo = toDate == null || date.isEqual(toDate) || date.isBefore(toDate);
                return afterFrom && beforeTo;
        }

        private boolean matchesExactOrAll(String value, String filter) {
                if (filter == null || filter.isBlank() || "ALL".equalsIgnoreCase(filter)) {
                        return true;
                }
                return value != null && value.equalsIgnoreCase(filter);
        }

        private boolean containsIgnoreCase(String source, String filter) {
                if (filter == null || filter.isBlank()) {
                        return true;
                }
                return source != null && source.toLowerCase(Locale.ROOT).contains(filter.toLowerCase(Locale.ROOT));
        }

        private boolean matchesKeyword(MaintenanceHistoryRecord record, String keyword) {
                if (keyword == null || keyword.isBlank()) {
                        return true;
                }

                String normalizedKeyword = keyword.toLowerCase(Locale.ROOT);
                String searchable = String.join(" ",
                                firstNonBlank(record.getEquipmentName(), ""),
                                firstNonBlank(record.getAssetId(), ""),
                                firstNonBlank(record.getTechnicianName(), ""),
                                firstNonBlank(record.getWorkPerformed(), ""),
                                firstNonBlank(record.getRemarks(), ""),
                                firstNonBlank(record.getStatus(), ""),
                                record.getMaintenanceDate() != null ? record.getMaintenanceDate().toString() : "");

                return searchable.toLowerCase(Locale.ROOT).contains(normalizedKeyword);
        }

        private String normalizeFilter(String value, String defaultValue) {
                if (value == null || value.isBlank()) {
                        return defaultValue;
                }
                return value.trim().toUpperCase(Locale.ROOT);
        }

        private String normalizeSortOrder(String sortOrder) {
                if (sortOrder == null || sortOrder.isBlank()) {
                        return "newest";
                }
                return sortOrder.trim().toLowerCase(Locale.ROOT);
        }

        private String firstNonBlank(String... values) {
                for (String value : values) {
                        if (value != null && !value.isBlank()) {
                                return value;
                        }
                }
                return "";
        }

        private String escapeCsv(String value) {
                if (value == null) {
                        return "";
                }
                String escaped = value.replace("\"", "\"\"");
                return "\"" + escaped + "\"";
        }
}
