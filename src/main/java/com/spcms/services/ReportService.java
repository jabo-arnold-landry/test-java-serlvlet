package com.spcms.services;

import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.BranchPerformanceReport;
import com.spcms.models.CostAnalysisReport;
import com.spcms.models.MonitoringLog;
import com.spcms.models.Incident;
import com.spcms.models.UpsMaintenance;
import com.spcms.models.CoolingMaintenance;
import com.spcms.repositories.*;
import com.spcms.util.ReportCalculationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

    @Autowired
    private DailyConsolidatedReportRepository dailyReportRepository;

    @Autowired
    private BranchPerformanceReportRepository branchPerformanceReportRepository;

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
    private UserRepository userRepository;

    @Autowired
    private CostAnalysisReportRepository costAnalysisReportRepository;

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

    // ==================== Branch Performance Report ====================

    /**
     * Generate a branch performance report for a specific branch and date.
     */
    public BranchPerformanceReport generateBranchPerformanceReport(String branch, LocalDate date) {
        // Check if already exists
        Optional<BranchPerformanceReport> existing = branchPerformanceReportRepository
                .findByBranchAndReportDate(branch, date);
        if (existing.isPresent()) {
            return existing.get();
        }

        LocalDateTime dayStart = date.atStartOfDay();
        LocalDateTime dayEnd = date.atTime(LocalTime.MAX);

        // === Get users for this branch ===
        List<Long> branchUserIds = userRepository.findByBranch(branch).stream()
                .map(u -> u.getUserId())
                .collect(Collectors.toList());
        int userCount = branchUserIds.size();

        // === UPS metrics (filtered by branch users) ===
        List<MonitoringLog> branchUpsLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.UPS, dayStart, dayEnd).stream()
                .filter(log -> log.getRecordedBy() != null && branchUserIds.contains(log.getRecordedBy().getUserId()))
                .collect(Collectors.toList());
        List<BigDecimal> loadReadings = branchUpsLogs.stream()
                .map(MonitoringLog::getLoadPercentage)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgDailyLoad = ReportCalculationUtil.calculateDailyAverageLoad(loadReadings);
        BigDecimal peakLoad = ReportCalculationUtil.findMax(loadReadings);

        // === Cooling metrics (filtered by branch users) ===
        List<MonitoringLog> branchCoolingLogs = monitoringLogRepository.findByTypeAndDateRange(
                MonitoringLog.EquipmentType.COOLING, dayStart, dayEnd).stream()
                .filter(log -> log.getRecordedBy() != null && branchUserIds.contains(log.getRecordedBy().getUserId()))
                .collect(Collectors.toList());
        List<BigDecimal> temperatures = branchCoolingLogs.stream()
                .map(MonitoringLog::getTemperature)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());
        BigDecimal avgRoomTemp = ReportCalculationUtil.calculateAverageTemperature(temperatures);
        BigDecimal highestTemp = ReportCalculationUtil.findMax(temperatures);

        // === Incident metrics (filtered by branch users) ===
        List<Incident> branchIncidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd).stream()
                .filter(inc -> (inc.getReportedBy() != null && branchUserIds.contains(inc.getReportedBy().getUserId())) ||
                               (inc.getAssignedTo() != null && branchUserIds.contains(inc.getAssignedTo().getUserId())))
                .collect(Collectors.toList());
        int totalIncidents = branchIncidents.size();
        int criticalIncidents = (int) branchIncidents.stream()
                .filter(inc -> inc.getSeverity() != null && inc.getSeverity().equals(Incident.Severity.CRITICAL))
                .count();
        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(dayStart, dayEnd);
        int downtimeMin = totalDowntime != null ? totalDowntime : 0;

        BigDecimal mttr = ReportCalculationUtil.calculateMTTR(downtimeMin, totalIncidents);
        BigDecimal mtbf = ReportCalculationUtil.calculateMTBF(24.0, downtimeMin, totalIncidents);

        // === Cooling Alarms ===
        int totalAlarms = coolingAlarmLogRepository.findByAlarmTimeBetween(dayStart, dayEnd).size();

        // === Visitors (global, but will be associated with records) ===
        int totalVisitors = visitorCheckInOutRepository.findActiveVisitors().size();

        // === Build branch report ===
        BranchPerformanceReport report = BranchPerformanceReport.builder()
                .branch(branch)
                .reportDate(date)
                .avgDailyLoad(avgDailyLoad)
                .peakLoad(peakLoad)
                .totalUpsAlarms(totalAlarms)
                .avgRoomTemperature(avgRoomTemp)
                .highestTempRecorded(highestTemp)
                .totalIncidents(totalIncidents)
                .criticalIncidents(criticalIncidents)
                .totalDowntimeMin(downtimeMin)
                .mttrMinutes(mttr)
                .mtbfHours(mtbf)
                .totalVisitors(totalVisitors)
                .userCount(userCount)
                .build();

        return branchPerformanceReportRepository.save(report);
    }

    /**
     * Get all available branches
     */
    public List<String> getAllBranches() {
        return userRepository.findAll().stream()
                .map(u -> u.getBranch())
                .distinct()
                .filter(b -> b != null && !b.isBlank())
                .sorted()
                .collect(Collectors.toList());
    }

    /**
     * Get branch performance report for a specific date and branch
     */
    public Optional<BranchPerformanceReport> getBranchPerformanceReport(String branch, LocalDate date) {
        return branchPerformanceReportRepository.findByBranchAndReportDate(branch, date);
    }

    /**
     * Get branch performance reports in a date range
     */
    public List<BranchPerformanceReport> getBranchPerformanceReportsInRange(String branch, LocalDate start, LocalDate end) {
        return branchPerformanceReportRepository
                .findByBranchAndReportDateBetweenOrderByReportDateDesc(branch, start, end);
    }

    /**
     * Get all branch reports for a specific date (for comparison)
     */
    public List<BranchPerformanceReport> getBranchPerformanceReportsByDate(LocalDate date) {
        return branchPerformanceReportRepository.findByReportDate(date);
    }

    // ==================== Cost Analysis Report ====================

    /**
     * Generate a comprehensive cost analysis report for a given date and optional branch.
     * Includes maintenance costs, repair costs, and downtime cost analysis.
     */
    public CostAnalysisReport generateCostAnalysisReport(LocalDate date, String branch) {
        try {
            // Check if already exists
            Optional<CostAnalysisReport> existing = branch != null && !branch.isBlank() ?
                    costAnalysisReportRepository.findByBranchAndReportDate(branch, date) :
                    costAnalysisReportRepository.findByReportDate(date);

            if (existing.isPresent()) {
                return existing.get();
            }

            // Normalize branch to null if blank
            if (branch != null && branch.isBlank()) {
                branch = null;
            }

            LocalDateTime dayStart = date.atStartOfDay();
            LocalDateTime dayEnd = date.atTime(LocalTime.MAX);

            // === Get users for branch filter ===
            List<Long> branchUserIds = new java.util.ArrayList<>();
            if (branch != null) {
                try {
                    branchUserIds = userRepository.findByBranch(branch).stream()
                            .map(u -> u.getUserId())
                            .collect(Collectors.toList());
                } catch (Exception e) {
                    System.out.println("Error fetching users for branch: " + branch + " - " + e.getMessage());
                    branchUserIds = new java.util.ArrayList<>();
                }
            }

        // === Maintenance Costs ===
        BigDecimal upsMaintenanceCost = calculateUpsMaintenanceCost(dayStart, dayEnd, branchUserIds);
        BigDecimal coolingMaintenanceCost = calculateCoolingMaintenanceCost(dayStart, dayEnd, branchUserIds);
        BigDecimal totalMaintenanceCost = upsMaintenanceCost.add(coolingMaintenanceCost);

        // === Preventive vs Corrective ===
        BigDecimal preventiveMaintenanceCost = calculatePreventiveMaintenanceCost(dayStart, dayEnd, branchUserIds);
        BigDecimal correctiveMaintenanceCost = calculateCorrectiveMaintenanceCost(dayStart, dayEnd, branchUserIds);

        // === Repair Costs from Incidents ===
        BigDecimal totalRepairCost = calculateIncidentRepairCost(dayStart, dayEnd, branchUserIds);
        BigDecimal criticalIncidentCost = calculateCriticalIncidentCost(dayStart, dayEnd, branchUserIds);

        // === Downtime Analysis ===
        Integer totalDowntimeMinutes = calculateTotalDowntime(dayStart, dayEnd, branchUserIds);
        BigDecimal costPerHourLoss = BigDecimal.valueOf(500); // Default: $500/hour downtime cost
        BigDecimal totalDowntimeCost = calculateDowntimeCost(totalDowntimeMinutes, costPerHourLoss);

        // === Summary ===
        BigDecimal totalOperationalCost = totalMaintenanceCost.add(totalRepairCost).add(totalDowntimeCost);
        BigDecimal maintenanceCostPerHour = calculateMaintenanceCostPerHour(totalMaintenanceCost);

        // === Incident Count ===
        int totalIncidents = countIncidents(dayStart, dayEnd, branchUserIds);
        int maintenanceEvents = countMaintenanceEvents(dayStart, dayEnd, branchUserIds);

        // === Build report ===
        CostAnalysisReport report = CostAnalysisReport.builder()
                .reportDate(date)
                .branch(branch)
                .totalMaintenanceCost(totalMaintenanceCost != null ? totalMaintenanceCost : BigDecimal.ZERO)
                .upsMaintenanceCost(upsMaintenanceCost != null ? upsMaintenanceCost : BigDecimal.ZERO)
                .coolingMaintenanceCost(coolingMaintenanceCost != null ? coolingMaintenanceCost : BigDecimal.ZERO)
                .preventiveMaintenanceCost(preventiveMaintenanceCost != null ? preventiveMaintenanceCost : BigDecimal.ZERO)
                .correctiveMaintenanceCost(correctiveMaintenanceCost != null ? correctiveMaintenanceCost : BigDecimal.ZERO)
                .totalRepairCost(totalRepairCost != null ? totalRepairCost : BigDecimal.ZERO)
                .criticalIncidentCost(criticalIncidentCost != null ? criticalIncidentCost : BigDecimal.ZERO)
                .totalDowntimeMinutes(totalDowntimeMinutes != null ? totalDowntimeMinutes : 0)
                .costPerHourLoss(costPerHourLoss)
                .totalDowntimeCost(totalDowntimeCost != null ? totalDowntimeCost : BigDecimal.ZERO)
                .totalOperationalCost(totalOperationalCost != null ? totalOperationalCost : BigDecimal.ZERO)
                .maintenanceCostPerHour(maintenanceCostPerHour != null ? maintenanceCostPerHour : BigDecimal.ZERO)
                .totalIncidents(totalIncidents)
                .maintenanceEvents(maintenanceEvents)
                .build();

            try {
                return costAnalysisReportRepository.save(report);
            } catch (Exception saveError) {
                System.out.println("Error saving cost analysis report: " + saveError.getMessage());
                saveError.printStackTrace();
                // Return the report without saving (for now)
                return report;
            }
        } catch (Exception e) {
            System.out.println("Error generating cost analysis report: " + e.getMessage());
            e.printStackTrace();
            // Return a basic report with calculated zeros
            return CostAnalysisReport.builder()
                    .reportDate(date)
                    .branch(branch)
                    .totalMaintenanceCost(BigDecimal.ZERO)
                    .upsMaintenanceCost(BigDecimal.ZERO)
                    .coolingMaintenanceCost(BigDecimal.ZERO)
                    .preventiveMaintenanceCost(BigDecimal.ZERO)
                    .correctiveMaintenanceCost(BigDecimal.ZERO)
                    .totalRepairCost(BigDecimal.ZERO)
                    .criticalIncidentCost(BigDecimal.ZERO)
                    .totalDowntimeMinutes(0)
                    .costPerHourLoss(BigDecimal.valueOf(500))
                    .totalDowntimeCost(BigDecimal.ZERO)
                    .totalOperationalCost(BigDecimal.ZERO)
                    .maintenanceCostPerHour(BigDecimal.ZERO)
                    .totalIncidents(0)
                    .maintenanceEvents(0)
                    .build();
        }
    }

    private BigDecimal calculateUpsMaintenanceCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<UpsMaintenance> records = upsMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        return records.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateCoolingMaintenanceCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<CoolingMaintenance> records = coolingMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        return records.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculatePreventiveMaintenanceCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<UpsMaintenance> upsMaint = upsMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceType() != null && m.getMaintenanceType().equals(UpsMaintenance.MaintenanceType.PREVENTIVE) &&
                        m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        List<CoolingMaintenance> coolingMaint = coolingMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceType() != null && m.getMaintenanceType().equals(CoolingMaintenance.MaintenanceType.PREVENTIVE) &&
                        m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        BigDecimal upsCost = upsMaint.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal coolingCost = coolingMaint.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return upsCost.add(coolingCost);
    }

    private BigDecimal calculateCorrectiveMaintenanceCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<UpsMaintenance> upsMaint = upsMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceType() != null && m.getMaintenanceType().equals(UpsMaintenance.MaintenanceType.CORRECTIVE) &&
                        m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        List<CoolingMaintenance> coolingMaint = coolingMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceType() != null && m.getMaintenanceType().equals(CoolingMaintenance.MaintenanceType.CORRECTIVE) &&
                        m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        BigDecimal upsCost = upsMaint.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal coolingCost = coolingMaint.stream()
                .map(m -> m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return upsCost.add(coolingCost);
    }

    private BigDecimal calculateIncidentRepairCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(start, end);

        if (!userIds.isEmpty()) {
            incidents = incidents.stream()
                    .filter(i -> (i.getReportedBy() != null && userIds.contains(i.getReportedBy().getUserId())) ||
                                 (i.getAssignedTo() != null && userIds.contains(i.getAssignedTo().getUserId())))
                    .collect(Collectors.toList());
        }

        return incidents.stream()
                .map(i -> i.getRepairCost() != null ? i.getRepairCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateCriticalIncidentCost(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(start, end).stream()
                .filter(i -> i.getSeverity() != null && i.getSeverity().equals(Incident.Severity.CRITICAL))
                .collect(Collectors.toList());

        if (!userIds.isEmpty()) {
            incidents = incidents.stream()
                    .filter(i -> (i.getReportedBy() != null && userIds.contains(i.getReportedBy().getUserId())) ||
                                 (i.getAssignedTo() != null && userIds.contains(i.getAssignedTo().getUserId())))
                    .collect(Collectors.toList());
        }

        return incidents.stream()
                .map(i -> i.getRepairCost() != null ? i.getRepairCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private Integer calculateTotalDowntime(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(start, end);
        return totalDowntime != null ? totalDowntime : 0;
    }

    private BigDecimal calculateDowntimeCost(Integer downtimeMinutes, BigDecimal costPerHourLoss) {
        if (downtimeMinutes == null || downtimeMinutes == 0) {
            return BigDecimal.ZERO;
        }
        double downtimeHours = downtimeMinutes / 60.0;
        return costPerHourLoss.multiply(BigDecimal.valueOf(downtimeHours));
    }

    private BigDecimal calculateMaintenanceCostPerHour(BigDecimal totalMaintenanceCost) {
        if (totalMaintenanceCost == null || totalMaintenanceCost.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO;
        }
        return totalMaintenanceCost.divide(BigDecimal.valueOf(24), 2, java.math.RoundingMode.HALF_UP);
    }

    private int countIncidents(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<Incident> incidents = incidentRepository.findByCreatedAtBetween(start, end);

        if (!userIds.isEmpty()) {
            incidents = incidents.stream()
                    .filter(i -> (i.getReportedBy() != null && userIds.contains(i.getReportedBy().getUserId())) ||
                                 (i.getAssignedTo() != null && userIds.contains(i.getAssignedTo().getUserId())))
                    .collect(Collectors.toList());
        }

        return incidents.size();
    }

    private int countMaintenanceEvents(LocalDateTime start, LocalDateTime end, List<Long> userIds) {
        List<UpsMaintenance> upsMaint = upsMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        List<CoolingMaintenance> coolingMaint = coolingMaintenanceRepository.findAll().stream()
                .filter(m -> m.getMaintenanceDate() != null && 
                        !m.getMaintenanceDate().isBefore(start.toLocalDate()) && 
                        !m.getMaintenanceDate().isAfter(end.toLocalDate()))
                .collect(Collectors.toList());

        return upsMaint.size() + coolingMaint.size();
    }

    /**
     * Get cost analysis report for a specific date
     */
    public Optional<CostAnalysisReport> getCostAnalysisReport(LocalDate date) {
        return costAnalysisReportRepository.findByReportDate(date);
    }

    /**
     * Get cost analysis report for a branch and date
     */
    public Optional<CostAnalysisReport> getCostAnalysisReport(String branch, LocalDate date) {
        return costAnalysisReportRepository.findByBranchAndReportDate(branch, date);
    }

    /**
     * Get cost analysis reports in a date range
     */
    public List<CostAnalysisReport> getCostAnalysisReportsInRange(LocalDate start, LocalDate end) {
        return costAnalysisReportRepository.findByReportDateBetweenOrderByReportDateDesc(start, end);
    }

    /**
     * Get cost analysis reports for a branch in a date range
     */
    public List<CostAnalysisReport> getCostAnalysisReportsInRange(String branch, LocalDate start, LocalDate end) {
        return costAnalysisReportRepository.findByBranchAndReportDateBetweenOrderByReportDateDesc(branch, start, end);
    }
}
