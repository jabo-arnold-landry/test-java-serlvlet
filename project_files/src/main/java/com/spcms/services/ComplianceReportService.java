package com.spcms.services;

import com.spcms.dto.reports.*;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ComplianceReportService {

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final ReportService reportService;

    public ComplianceReportService(NamedParameterJdbcTemplate jdbcTemplate, ReportService reportService) {
        this.jdbcTemplate = jdbcTemplate;
        this.reportService = reportService;
    }

    public ReportResponseDto<EquipmentHealthReportDto> getEquipmentHealthReport(ReportFilterDto filter) {
        MapSqlParameterSource params = baseParams(filter);
        params.addValue("highRiskThreshold", defaultIfNull(filter.getHighRiskThreshold(), 3));

        String sql = """
                SELECT e.*
                FROM (
                    SELECT
                        'UPS' AS equipment_type,
                        u.ups_id AS equipment_id,
                        u.ups_name AS equipment_name,
                        u.asset_tag AS asset_tag,
                        CONCAT(COALESCE(u.location_room, ''), ' ', COALESCE(u.location_zone, '')) AS location,
                        u.load_percentage AS load_percentage,
                        ub.battery_health_status AS battery_health_status,
                        ub.estimated_runtime_min AS estimated_runtime_min,
                        NULL AS room_temperature,
                        NULL AS humidity_percent,
                        NULL AS compressor_status,
                        u.status AS equipment_status,
                        CASE
                            WHEN u.status = 'FAULTY' OR ub.battery_health_status = 'CRITICAL' THEN 'CRITICAL'
                            WHEN ub.battery_health_status IN ('POOR', 'REPLACE') THEN 'WARNING'
                            ELSE 'GOOD'
                        END AS health_status,
                        COALESCE(ic.incident_count, 0) AS incident_count,
                        CASE WHEN COALESCE(ic.incident_count, 0) > :highRiskThreshold THEN TRUE ELSE FALSE END AS high_risk
                    FROM ups u
                    LEFT JOIN ups_battery ub ON ub.ups_id = u.ups_id
                    LEFT JOIN (
                        SELECT equipment_type, equipment_id, COUNT(*) AS incident_count
                        FROM incidents
                        GROUP BY equipment_type, equipment_id
                    ) ic ON ic.equipment_type = 'UPS' AND ic.equipment_id = u.ups_id

                    UNION ALL

                    SELECT
                        'COOLING' AS equipment_type,
                        c.cooling_id AS equipment_id,
                        c.unit_name AS equipment_name,
                        c.asset_tag AS asset_tag,
                        CONCAT(COALESCE(c.location_room, ''), ' ', COALESCE(c.location_zone, '')) AS location,
                        NULL AS load_percentage,
                        NULL AS battery_health_status,
                        NULL AS estimated_runtime_min,
                        c.room_temperature AS room_temperature,
                        c.humidity_percent AS humidity_percent,
                        c.compressor_status AS compressor_status,
                        c.status AS equipment_status,
                        CASE
                            WHEN c.status = 'FAULTY' OR c.compressor_status = 'STOPPED' THEN 'CRITICAL'
                            WHEN c.room_temperature > 28 OR c.humidity_percent > 65 THEN 'WARNING'
                            ELSE 'GOOD'
                        END AS health_status,
                        COALESCE(ic.incident_count, 0) AS incident_count,
                        CASE WHEN COALESCE(ic.incident_count, 0) > :highRiskThreshold THEN TRUE ELSE FALSE END AS high_risk
                    FROM cooling_unit c
                    LEFT JOIN (
                        SELECT equipment_type, equipment_id, COUNT(*) AS incident_count
                        FROM incidents
                        GROUP BY equipment_type, equipment_id
                    ) ic ON ic.equipment_type = 'COOLING' AND ic.equipment_id = c.cooling_id
                ) e
                WHERE (:equipmentType IS NULL OR e.equipment_type = :equipmentType)
                  AND (:location IS NULL OR e.location LIKE CONCAT('%', :location, '%'))
                  AND (:branch IS NULL OR e.location LIKE CONCAT('%', :branch, '%'))
                ORDER BY e.health_status DESC, e.incident_count DESC, e.equipment_type, e.equipment_name
                """;

        List<EquipmentHealthReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                EquipmentHealthReportDto.builder()
                        .equipmentType(rs.getString("equipment_type"))
                        .equipmentId(rs.getLong("equipment_id"))
                        .equipmentName(rs.getString("equipment_name"))
                        .assetTag(rs.getString("asset_tag"))
                        .location(rs.getString("location"))
                        .loadPercentage(toDouble(rs.getObject("load_percentage")))
                        .batteryHealthStatus(rs.getString("battery_health_status"))
                        .estimatedRuntimeMin(toInteger(rs.getObject("estimated_runtime_min")))
                        .roomTemperature(toDouble(rs.getObject("room_temperature")))
                        .humidityPercent(toDouble(rs.getObject("humidity_percent")))
                        .compressorStatus(rs.getString("compressor_status"))
                        .equipmentStatus(rs.getString("equipment_status"))
                        .healthStatus(rs.getString("health_status"))
                        .incidentCount(toInteger(rs.getObject("incident_count")))
                        .highRisk(rs.getBoolean("high_risk"))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalEquipment", rows.size());
        summary.put("criticalCount", rows.stream().filter(r -> "CRITICAL".equalsIgnoreCase(r.getHealthStatus())).count());
        summary.put("warningCount", rows.stream().filter(r -> "WARNING".equalsIgnoreCase(r.getHealthStatus())).count());
        summary.put("highRiskCount", rows.stream().filter(r -> Boolean.TRUE.equals(r.getHighRisk())).count());

        return ReportResponseDto.<EquipmentHealthReportDto>builder()
                .reportName("Equipment Health Report")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    public ReportResponseDto<MaintenanceHistoryReportDto> getMaintenanceHistoryReport(ReportFilterDto filter) {
        MapSqlParameterSource params = baseParams(filter);

        String sql = """
                SELECT m.*
                FROM (
                    SELECT
                        'UPS' AS equipment_type,
                        um.maintenance_id AS maintenance_id,
                        u.ups_id AS equipment_id,
                        u.ups_name AS equipment_name,
                        um.maintenance_type AS maintenance_type,
                        um.maintenance_date AS maintenance_date,
                        um.next_due_date AS next_due_date,
                        um.technician AS technician,
                        um.vendor AS vendor,
                        CASE WHEN um.next_due_date < CURRENT_DATE THEN 'OVERDUE' ELSE 'ON_TIME' END AS maintenance_status,
                        um.remarks AS remarks,
                        CONCAT(COALESCE(u.location_room, ''), ' ', COALESCE(u.location_zone, '')) AS location
                    FROM ups_maintenance um
                    JOIN ups u ON u.ups_id = um.ups_id

                    UNION ALL

                    SELECT
                        'COOLING' AS equipment_type,
                        cm.maintenance_id AS maintenance_id,
                        c.cooling_id AS equipment_id,
                        c.unit_name AS equipment_name,
                        cm.maintenance_type AS maintenance_type,
                        cm.maintenance_date AS maintenance_date,
                        cm.next_maintenance_date AS next_due_date,
                        cm.technician AS technician,
                        cm.vendor AS vendor,
                        CASE WHEN cm.next_maintenance_date < CURRENT_DATE THEN 'OVERDUE' ELSE 'ON_TIME' END AS maintenance_status,
                        cm.remarks AS remarks,
                        CONCAT(COALESCE(c.location_room, ''), ' ', COALESCE(c.location_zone, '')) AS location
                    FROM cooling_maintenance cm
                    JOIN cooling_unit c ON c.cooling_id = cm.cooling_id
                ) m
                WHERE (:startDate IS NULL OR m.maintenance_date >= :startDate)
                  AND (:endDate IS NULL OR m.maintenance_date <= :endDate)
                  AND (:equipmentType IS NULL OR m.equipment_type = :equipmentType)
                  AND (:technician IS NULL OR m.technician LIKE CONCAT('%', :technician, '%'))
                  AND (:location IS NULL OR m.location LIKE CONCAT('%', :location, '%'))
                  AND (:branch IS NULL OR m.location LIKE CONCAT('%', :branch, '%'))
                ORDER BY m.maintenance_date DESC, m.maintenance_status DESC
                """;

        List<MaintenanceHistoryReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                MaintenanceHistoryReportDto.builder()
                        .equipmentType(rs.getString("equipment_type"))
                        .maintenanceId(rs.getLong("maintenance_id"))
                        .equipmentId(rs.getLong("equipment_id"))
                        .equipmentName(rs.getString("equipment_name"))
                        .maintenanceType(rs.getString("maintenance_type"))
                        .maintenanceDate(toLocalDate(rs.getObject("maintenance_date")))
                        .nextDueDate(toLocalDate(rs.getObject("next_due_date")))
                        .technician(rs.getString("technician"))
                        .vendor(rs.getString("vendor"))
                        .maintenanceStatus(rs.getString("maintenance_status"))
                        .remarks(rs.getString("remarks"))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalMaintenanceRecords", rows.size());
        summary.put("overdueCount", rows.stream().filter(r -> "OVERDUE".equalsIgnoreCase(r.getMaintenanceStatus())).count());
        summary.put("preventiveCount", rows.stream().filter(r -> "PREVENTIVE".equalsIgnoreCase(r.getMaintenanceType())).count());
        summary.put("correctiveCount", rows.stream().filter(r -> "CORRECTIVE".equalsIgnoreCase(r.getMaintenanceType())).count());

        return ReportResponseDto.<MaintenanceHistoryReportDto>builder()
                .reportName("Maintenance History Report")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    public ReportResponseDto<IncidentDowntimeReportDto> getIncidentDowntimeReport(ReportFilterDto filter) {
        MapSqlParameterSource params = baseParams(filter);
        params.addValue("downtimeThreshold", defaultIfNull(filter.getDowntimeThreshold(), 120));

        String sql = """
                SELECT
                    i.incident_id,
                    i.title,
                    i.equipment_type,
                    i.equipment_id,
                    i.severity,
                    COALESCE(i.downtime_minutes, 0) AS downtime_minutes,
                    i.root_cause,
                    i.status,
                    COALESCE(u.full_name, u.username, 'Unassigned') AS technician,
                    i.created_at,
                    CASE WHEN COALESCE(i.downtime_minutes, 0) > :downtimeThreshold THEN TRUE ELSE FALSE END AS sla_violation
                FROM incidents i
                LEFT JOIN users u ON u.user_id = i.assigned_to
                WHERE (:startDate IS NULL OR DATE(i.created_at) >= :startDate)
                  AND (:endDate IS NULL OR DATE(i.created_at) <= :endDate)
                  AND (:equipmentType IS NULL OR i.equipment_type = :equipmentType)
                  AND (:technician IS NULL OR COALESCE(u.full_name, u.username, '') LIKE CONCAT('%', :technician, '%'))
                ORDER BY i.created_at DESC, i.severity DESC
                """;

        List<IncidentDowntimeReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                IncidentDowntimeReportDto.builder()
                        .incidentId(rs.getLong("incident_id"))
                        .title(rs.getString("title"))
                        .equipmentType(rs.getString("equipment_type"))
                        .equipmentId(toLong(rs.getObject("equipment_id")))
                        .severity(rs.getString("severity"))
                        .downtimeMinutes(toInteger(rs.getObject("downtime_minutes")))
                        .rootCause(rs.getString("root_cause"))
                        .status(rs.getString("status"))
                        .technician(rs.getString("technician"))
                        .createdAt(toLocalDateTime(rs.getObject("created_at")))
                        .slaViolation(rs.getBoolean("sla_violation"))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalIncidents", rows.size());
        summary.put("totalDowntimeMinutes", rows.stream().map(IncidentDowntimeReportDto::getDowntimeMinutes).filter(v -> v != null).mapToInt(Integer::intValue).sum());
        summary.put("criticalIncidents", rows.stream().filter(r -> "CRITICAL".equalsIgnoreCase(r.getSeverity())).count());
        summary.put("slaViolations", rows.stream().filter(r -> Boolean.TRUE.equals(r.getSlaViolation())).count());

        return ReportResponseDto.<IncidentDowntimeReportDto>builder()
                .reportName("Incident & Downtime Report")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    public ReportResponseDto<ShiftTechnicianReportDto> getShiftTechnicianReport(Long shiftId, ReportFilterDto filter) {
        MapSqlParameterSource params = baseParams(filter);
        params.addValue("shiftId", shiftId);

        String sql = """
                SELECT
                    sr.report_id,
                    COALESCE(u.full_name, u.username, 'Unknown') AS technician,
                    sr.shift_type,
                    sr.shift_date,
                    sr.num_incidents AS incidents_handled,
                    sr.downtime_duration_min,
                    CONCAT('Preventive: ', COALESCE(sr.preventive_maint_done, '-'), ' | Corrective: ', COALESCE(sr.corrective_maint_done, '-')) AS maintenance_performed,
                    shn.system_status_summary,
                    shn.pending_issues,
                    shn.recommendations
                FROM shift_reports sr
                LEFT JOIN users u ON u.user_id = sr.staff_id
                LEFT JOIN shift_handover_notes shn ON shn.shift_report_id = sr.report_id
                WHERE (:shiftId IS NULL OR sr.report_id = :shiftId)
                  AND (:startDate IS NULL OR sr.shift_date >= :startDate)
                  AND (:endDate IS NULL OR sr.shift_date <= :endDate)
                  AND (:technician IS NULL OR COALESCE(u.full_name, u.username, '') LIKE CONCAT('%', :technician, '%'))
                  AND (:technicianId IS NULL OR sr.staff_id = :technicianId)
                ORDER BY sr.shift_date DESC, sr.report_id DESC
                """;

        List<ShiftTechnicianReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                ShiftTechnicianReportDto.builder()
                        .reportId(rs.getLong("report_id"))
                        .technician(rs.getString("technician"))
                        .shiftType(rs.getString("shift_type"))
                        .shiftDate(toLocalDate(rs.getObject("shift_date")))
                        .incidentsHandled(toInteger(rs.getObject("incidents_handled")))
                        .downtimeDurationMin(toInteger(rs.getObject("downtime_duration_min")))
                        .maintenancePerformed(rs.getString("maintenance_performed"))
                        .systemStatusSummary(rs.getString("system_status_summary"))
                        .pendingIssues(rs.getString("pending_issues"))
                        .recommendations(rs.getString("recommendations"))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalShiftReports", rows.size());
        summary.put("totalIncidentsHandled", rows.stream().map(ShiftTechnicianReportDto::getIncidentsHandled).filter(v -> v != null).mapToInt(Integer::intValue).sum());
        summary.put("totalDowntimeMinutes", rows.stream().map(ShiftTechnicianReportDto::getDowntimeDurationMin).filter(v -> v != null).mapToInt(Integer::intValue).sum());

        return ReportResponseDto.<ShiftTechnicianReportDto>builder()
                .reportName("Shift Report (Per Technician)")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    public ReportResponseDto<DailyConsolidatedReportDto> getDailyConsolidatedReport(ReportFilterDto filter, boolean autoGenerate) {
        if (autoGenerate) {
            LocalDate start = filter.getStartDate() != null ? filter.getStartDate() : LocalDate.now();
            LocalDate end = filter.getEndDate() != null ? filter.getEndDate() : start;
            LocalDate cursor = start;
            while (!cursor.isAfter(end)) {
                reportService.generateDailyReport(cursor);
                cursor = cursor.plusDays(1);
            }
        }

        MapSqlParameterSource params = baseParams(filter);

        String sql = """
                SELECT
                    report_id,
                    report_date,
                    avg_daily_load,
                    battery_status_summary,
                    avg_room_temperature,
                    highest_temp_recorded,
                    mttr_minutes,
                    mtbf_hours,
                    total_downtime_min,
                    total_incidents
                FROM daily_consolidated_reports
                WHERE (:startDate IS NULL OR report_date >= :startDate)
                  AND (:endDate IS NULL OR report_date <= :endDate)
                ORDER BY report_date DESC
                """;

        List<DailyConsolidatedReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                DailyConsolidatedReportDto.builder()
                        .reportId(rs.getLong("report_id"))
                        .reportDate(toLocalDate(rs.getObject("report_date")))
                        .avgDailyLoad(rs.getBigDecimal("avg_daily_load"))
                        .batteryStatusSummary(rs.getString("battery_status_summary"))
                        .avgRoomTemperature(rs.getBigDecimal("avg_room_temperature"))
                        .highestTempRecorded(rs.getBigDecimal("highest_temp_recorded"))
                        .mttrMinutes(rs.getBigDecimal("mttr_minutes"))
                        .mtbfHours(rs.getBigDecimal("mtbf_hours"))
                        .totalDowntimeMin(toInteger(rs.getObject("total_downtime_min")))
                        .totalIncidents(toInteger(rs.getObject("total_incidents")))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalReports", rows.size());
        summary.put("totalDowntimeMinutes", rows.stream().map(DailyConsolidatedReportDto::getTotalDowntimeMin).filter(v -> v != null).mapToInt(Integer::intValue).sum());
        summary.put("avgMttr", rows.stream().map(DailyConsolidatedReportDto::getMttrMinutes).filter(v -> v != null).findFirst().orElse(null));

        return ReportResponseDto.<DailyConsolidatedReportDto>builder()
                .reportName("Daily Consolidated Report")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    public ReportResponseDto<ComplianceReportDto> getComplianceReport(ReportFilterDto filter) {
        MapSqlParameterSource params = baseParams(filter);
        params.addValue("highRiskThreshold", defaultIfNull(filter.getHighRiskThreshold(), 3));
        params.addValue("downtimeThreshold", defaultIfNull(filter.getDowntimeThreshold(), 120));

        String sql = """
                SELECT c.*
                FROM (
                    SELECT
                        'OVERDUE_MAINTENANCE' AS issue_type,
                        'HIGH' AS severity,
                        'UPS_MAINTENANCE' AS reference_type,
                        um.maintenance_id AS reference_id,
                        CONCAT('UPS ', u.ups_name, ' maintenance overdue since ', um.next_due_date) AS details,
                        'Schedule immediate preventive maintenance' AS recommended_action,
                        'OPEN' AS status,
                        um.created_at AS created_at,
                        CONCAT(COALESCE(u.location_room, ''), ' ', COALESCE(u.location_zone, '')) AS location
                    FROM ups_maintenance um
                    JOIN ups u ON u.ups_id = um.ups_id
                    WHERE um.next_due_date < CURRENT_DATE

                    UNION ALL

                    SELECT
                        'OVERDUE_MAINTENANCE' AS issue_type,
                        'HIGH' AS severity,
                        'COOLING_MAINTENANCE' AS reference_type,
                        cm.maintenance_id AS reference_id,
                        CONCAT('Cooling ', c.unit_name, ' maintenance overdue since ', cm.next_maintenance_date) AS details,
                        'Schedule immediate preventive maintenance' AS recommended_action,
                        'OPEN' AS status,
                        cm.created_at AS created_at,
                        CONCAT(COALESCE(c.location_room, ''), ' ', COALESCE(c.location_zone, '')) AS location
                    FROM cooling_maintenance cm
                    JOIN cooling_unit c ON c.cooling_id = cm.cooling_id
                    WHERE cm.next_maintenance_date < CURRENT_DATE

                    UNION ALL

                    SELECT
                        'SLA_VIOLATION' AS issue_type,
                        'CRITICAL' AS severity,
                        'INCIDENTS' AS reference_type,
                        MAX(i.incident_id) AS reference_id,
                        CONCAT('Equipment ', i.equipment_type, '#', i.equipment_id,
                               ' has ', COUNT(*), ' incidents and ', COALESCE(SUM(i.downtime_minutes), 0), ' downtime minutes') AS details,
                        'Perform root-cause analysis and mitigation plan' AS recommended_action,
                        'OPEN' AS status,
                        MAX(i.created_at) AS created_at,
                        NULL AS location
                    FROM incidents i
                    GROUP BY i.equipment_type, i.equipment_id
                    HAVING COUNT(*) > :highRiskThreshold OR COALESCE(SUM(i.downtime_minutes), 0) > :downtimeThreshold

                    UNION ALL

                    SELECT
                        'CRITICAL_ALERT' AS issue_type,
                        'CRITICAL' AS severity,
                        'ALERT' AS reference_type,
                        a.alert_id AS reference_id,
                        CONCAT(a.alert_type, ' - ', a.message) AS details,
                        'Acknowledge and investigate immediately' AS recommended_action,
                        CASE WHEN a.is_acknowledged = 1 THEN 'CLOSED' ELSE 'OPEN' END AS status,
                        a.created_at AS created_at,
                        NULL AS location
                    FROM alerts a
                    WHERE a.is_acknowledged = 0
                ) c
                WHERE (:startDate IS NULL OR DATE(c.created_at) >= :startDate)
                  AND (:endDate IS NULL OR DATE(c.created_at) <= :endDate)
                  AND (:location IS NULL OR c.location LIKE CONCAT('%', :location, '%'))
                  AND (:branch IS NULL OR c.location LIKE CONCAT('%', :branch, '%'))
                ORDER BY c.severity DESC, c.created_at DESC
                """;

        List<ComplianceReportDto> rows = jdbcTemplate.query(sql, params, (rs, rowNum) ->
                ComplianceReportDto.builder()
                        .issueType(rs.getString("issue_type"))
                        .severity(rs.getString("severity"))
                        .referenceType(rs.getString("reference_type"))
                        .referenceId(toLong(rs.getObject("reference_id")))
                        .details(rs.getString("details"))
                        .recommendedAction(rs.getString("recommended_action"))
                        .status(rs.getString("status"))
                        .createdAt(toLocalDateTime(rs.getObject("created_at")))
                        .build()
        );

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalIssues", rows.size());
        summary.put("overdueMaintenance", rows.stream().filter(r -> "OVERDUE_MAINTENANCE".equalsIgnoreCase(r.getIssueType())).count());
        summary.put("slaViolations", rows.stream().filter(r -> "SLA_VIOLATION".equalsIgnoreCase(r.getIssueType())).count());
        summary.put("criticalAlerts", rows.stream().filter(r -> "CRITICAL_ALERT".equalsIgnoreCase(r.getIssueType())).count());

        return ReportResponseDto.<ComplianceReportDto>builder()
                .reportName("Compliance Report")
                .generatedAt(LocalDateTime.now())
                .filters(filter)
                .rows(rows)
                .summary(summary)
                .build();
    }

    private MapSqlParameterSource baseParams(ReportFilterDto filter) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("startDate", toSqlDate(filter.getStartDate()));
        params.addValue("endDate", toSqlDate(filter.getEndDate()));
        params.addValue("equipmentType", emptyToNull(filter.getEquipmentType()));
        params.addValue("branch", emptyToNull(filter.getBranch()));
        params.addValue("location", emptyToNull(filter.getLocation()));
        params.addValue("technician", emptyToNull(filter.getTechnician()));
        params.addValue("technicianId", filter.getTechnicianId());
        return params;
    }

    private Date toSqlDate(LocalDate date) {
        return date == null ? null : Date.valueOf(date);
    }

    private String emptyToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    private Integer defaultIfNull(Integer value, Integer defaultValue) {
        return value == null ? defaultValue : value;
    }

    private LocalDate toLocalDate(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Date sqlDate) {
            return sqlDate.toLocalDate();
        }
        if (value instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime().toLocalDate();
        }
        if (value instanceof LocalDate localDate) {
            return localDate;
        }
        return null;
    }

    private LocalDateTime toLocalDateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime();
        }
        if (value instanceof LocalDateTime localDateTime) {
            return localDateTime;
        }
        return null;
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.intValue();
        }
        return null;
    }

    private Long toLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        return null;
    }

    private Double toDouble(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.doubleValue();
        }
        return null;
    }
}
