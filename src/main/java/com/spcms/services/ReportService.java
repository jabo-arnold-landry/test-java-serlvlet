package com.spcms.services;

import com.spcms.dto.EquipmentHealthRow;
import com.spcms.dto.MaintenanceHistoryRow;
import com.spcms.models.CoolingMaintenance;
import com.spcms.models.DailyConsolidatedReport;
import com.spcms.models.Equipment;
import com.spcms.models.Incident;
import com.spcms.models.MonitoringLog;
import com.spcms.models.UpsMaintenance;
import com.spcms.repositories.*;
import com.spcms.util.ReportCalculationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
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
    private VisitorCheckInOutRepository visitorCheckInOutRepository;

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private UpsMaintenanceRepository upsMaintenanceRepository;

    @Autowired
    private CoolingMaintenanceRepository coolingMaintenanceRepository;

    // ==================== Daily Consolidated Report ====================

        /**
         * Generate or retrieve the daily consolidated report for a given date.
         * This auto-calculates MTTR, MTBF, average load, temperature, etc.
         */
        @Transactional(noRollbackFor = Exception.class)
        public DailyConsolidatedReport generateDailyReport(LocalDate date) {
                // Check if report already exists
                Optional<DailyConsolidatedReport> existing = dailyReportRepository.findByReportDate(date);
                if (existing.isPresent()) {
                        return existing.get();
                }

                LocalDateTime dayStart = date.atStartOfDay();
                LocalDateTime dayEnd = date.atTime(LocalTime.MAX);

                BigDecimal avgDailyLoad = BigDecimal.ZERO;
                BigDecimal avgRoomTemp = BigDecimal.ZERO;
                BigDecimal highestTemp = BigDecimal.ZERO;
                int totalIncidents = 0;
                int criticalIncidents = 0;
                int downtimeMin = 0;
                BigDecimal mttr = BigDecimal.ZERO;
                BigDecimal mtbf = BigDecimal.valueOf(24).setScale(2);
                int totalAlarms = 0;
                int totalVisitors = 0;

                // === Calculate UPS metrics ===
                try {
                        List<MonitoringLog> upsLogs = monitoringLogRepository.findByTypeAndDateRange(
                                        MonitoringLog.EquipmentType.UPS, dayStart, dayEnd);
                        List<BigDecimal> loadReadings = upsLogs.stream()
                                        .map(MonitoringLog::getLoadPercentage)
                                        .filter(java.util.Objects::nonNull)
                                        .collect(Collectors.toList());
                        avgDailyLoad = ReportCalculationUtil.calculateDailyAverageLoad(loadReadings);
                } catch (Exception e) {
                        // UPS data unavailable - continue with defaults
                }

                // === Calculate Cooling metrics ===
                try {
                        List<MonitoringLog> coolingLogs = monitoringLogRepository.findByTypeAndDateRange(
                                        MonitoringLog.EquipmentType.COOLING, dayStart, dayEnd);
                        List<BigDecimal> temperatures = coolingLogs.stream()
                                        .map(MonitoringLog::getTemperature)
                                        .filter(java.util.Objects::nonNull)
                                        .collect(Collectors.toList());
                        avgRoomTemp = ReportCalculationUtil.calculateAverageTemperature(temperatures);
                        highestTemp = ReportCalculationUtil.findMax(temperatures);
                } catch (Exception e) {
                        // Cooling data unavailable - continue with defaults
                }

                // === Calculate Incident metrics ===
                try {
                        List<Incident> dailyIncidents = incidentRepository.findByCreatedAtBetween(dayStart, dayEnd);
                        totalIncidents = dailyIncidents.size();
                        Integer totalDowntime = incidentRepository.sumDowntimeMinutes(dayStart, dayEnd);
                        downtimeMin = totalDowntime != null ? totalDowntime : 0;
                        Long critCount = incidentRepository.countCriticalIncidents(dayStart, dayEnd);
                        criticalIncidents = critCount != null ? critCount.intValue() : 0;
                        mttr = ReportCalculationUtil.calculateMTTR(downtimeMin, totalIncidents);
                        mtbf = ReportCalculationUtil.calculateMTBF(24.0, downtimeMin, totalIncidents);
                } catch (Exception e) {
                        // Incident data unavailable - continue with defaults
                }

                // === Cooling Alarms ===
                try {
                        totalAlarms = coolingAlarmLogRepository.findByAlarmTimeBetween(dayStart, dayEnd).size();
                } catch (Exception e) {
                        // Alarm data unavailable
                }

                // === Active Visitors ===
                try {
                        totalVisitors = visitorCheckInOutRepository.findActiveVisitors().size();
                } catch (Exception e) {
                        // Visitor data unavailable
                }

                // === Build report ===
                DailyConsolidatedReport report = DailyConsolidatedReport.builder()
                                .reportDate(date)
                                .avgDailyLoad(avgDailyLoad)
                                .totalUpsAlarms(totalAlarms)
                                .avgRoomTemperature(avgRoomTemp)
                                .highestTempRecorded(highestTemp)
                                .totalIncidents(totalIncidents)
                                .criticalIncidents(criticalIncidents)
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

    // ==================== Equipment Health Report ====================

    public List<EquipmentHealthRow> getEquipmentHealthReport(LocalDate asOfDate) {
        LocalDate today = asOfDate != null ? asOfDate : LocalDate.now();
        LocalDateTime incidentStart = today.minusDays(30).atStartOfDay();
        LocalDateTime incidentEnd = today.atTime(LocalTime.MAX);

        List<Equipment> equipment = equipmentRepository.findAll();
        List<EquipmentHealthRow> rows = new ArrayList<>(equipment.size());

        for (Equipment e : equipment) {
            boolean maintenanceOverdue = isDateBefore(e.getNextMaintenanceDue(), today);
            boolean warrantyExpired = isDateBefore(e.getWarrantyExpiryDate(), today);
            boolean warrantyExpiring = isDateWithin(e.getWarrantyExpiryDate(), today, 30);
            boolean endOfLife = isDateBefore(e.getEndOfLife(), today);
            boolean endOfLifeSoon = isDateWithin(e.getEndOfLife(), today, 90);

            long incidentsLast30Days = 0;
            if (e.getEquipmentId() != null) {
                Long count = incidentRepository.countByEquipmentTypeAndEquipmentIdAndCreatedAtBetween(
                        Incident.EquipmentType.OTHER, e.getEquipmentId(), incidentStart, incidentEnd);
                incidentsLast30Days = count != null ? count : 0;
            }

            String healthStatus = deriveEquipmentHealthStatus(
                    e.getMaintenanceStatus(), maintenanceOverdue, warrantyExpired, endOfLife, incidentsLast30Days);

            rows.add(new EquipmentHealthRow(
                    e,
                    healthStatus,
                    maintenanceOverdue,
                    warrantyExpired,
                    warrantyExpiring,
                    endOfLife,
                    endOfLifeSoon,
                    incidentsLast30Days,
                    daysBetween(today, e.getNextMaintenanceDue()),
                    daysBetween(today, e.getWarrantyExpiryDate()),
                    daysBetween(today, e.getEndOfLife())
            ));
        }

        rows.sort(Comparator
                .comparingInt(this::healthRank)
                .thenComparing(r -> r.getEquipment().getEquipmentName() != null ? r.getEquipment().getEquipmentName() : ""));
        return rows;
    }

    // ==================== Maintenance History Report ====================

    public List<MaintenanceHistoryRow> getMaintenanceHistory(LocalDate start, LocalDate end) {
        LocalDate startDate = start != null ? start : LocalDate.now().minusDays(30);
        LocalDate endDate = end != null ? end : LocalDate.now();
        if (startDate.isAfter(endDate)) {
            LocalDate tmp = startDate;
            startDate = endDate;
            endDate = tmp;
        }

        List<MaintenanceHistoryRow> rows = new ArrayList<>();

        for (UpsMaintenance m : upsMaintenanceRepository.findByMaintenanceDateBetween(startDate, endDate)) {
            String assetTag = m.getUps() != null ? m.getUps().getAssetTag() : "Unknown";
            String assetName = m.getUps() != null ? m.getUps().getUpsName() : "Unknown";
            rows.add(new MaintenanceHistoryRow(
                    "UPS",
                    assetTag,
                    assetName,
                    m.getMaintenanceType() != null ? m.getMaintenanceType().name() : "N/A",
                    m.getMaintenanceDate(),
                    m.getNextDueDate(),
                    m.getTechnician(),
                    m.getVendor(),
                    m.getRemarks()
            ));
        }

        for (CoolingMaintenance m : coolingMaintenanceRepository.findByMaintenanceDateBetween(startDate, endDate)) {
            String assetTag = m.getCoolingUnit() != null ? m.getCoolingUnit().getAssetTag() : "Unknown";
            String assetName = m.getCoolingUnit() != null ? m.getCoolingUnit().getUnitName() : "Unknown";
            rows.add(new MaintenanceHistoryRow(
                    "Cooling",
                    assetTag,
                    assetName,
                    m.getMaintenanceType() != null ? m.getMaintenanceType().name() : "N/A",
                    m.getMaintenanceDate(),
                    m.getNextMaintenanceDate(),
                    m.getTechnician(),
                    m.getVendor(),
                    m.getRemarks()
            ));
        }

        rows.sort(Comparator.comparing(MaintenanceHistoryRow::getMaintenanceDate,
                Comparator.nullsLast(Comparator.naturalOrder())).reversed());
        return rows;
    }

    private boolean isDateBefore(LocalDate date, LocalDate reference) {
        return date != null && date.isBefore(reference);
    }

    private boolean isDateWithin(LocalDate date, LocalDate reference, int days) {
        return date != null && !date.isBefore(reference) && !date.isAfter(reference.plusDays(days));
    }

    private Long daysBetween(LocalDate from, LocalDate to) {
        return to == null ? null : ChronoUnit.DAYS.between(from, to);
    }

    private String deriveEquipmentHealthStatus(Equipment.MaintenanceStatus status,
                                               boolean maintenanceOverdue,
                                               boolean warrantyExpired,
                                               boolean endOfLife,
                                               long incidentsLast30Days) {
        if (status == Equipment.MaintenanceStatus.DECOMMISSIONED) {
            return "Decommissioned";
        }
        if (status == Equipment.MaintenanceStatus.FAULTY) {
            return "Critical";
        }
        if (status == Equipment.MaintenanceStatus.UNDER_REPAIR) {
            return "At Risk";
        }
        if (maintenanceOverdue || warrantyExpired || endOfLife || incidentsLast30Days >= 3) {
            return "Needs Attention";
        }
        return "Healthy";
    }

    private int healthRank(EquipmentHealthRow row) {
        String status = row.getHealthStatus();
        if ("Critical".equals(status)) return 1;
        if ("At Risk".equals(status)) return 2;
        if ("Needs Attention".equals(status)) return 3;
        if ("Healthy".equals(status)) return 4;
        return 5;
    }
}
