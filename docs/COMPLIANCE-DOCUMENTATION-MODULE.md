# Compliance & Documentation Module (SPCMS)

This module is implemented on branch `ftdivine` and uses existing SPCMS tables.

## 1) SQL Queries Used By Report APIs

### 1. Equipment Health Report
Tables: `ups`, `ups_battery`, `cooling_unit`, `incidents`

```sql
SELECT e.*
FROM (
    SELECT
        'UPS' AS equipment_type,
        u.ups_id AS equipment_id,
        u.ups_name AS equipment_name,
        u.asset_tag,
        CONCAT(COALESCE(u.location_room, ''), ' ', COALESCE(u.location_zone, '')) AS location,
        u.load_percentage,
        ub.battery_health_status,
        ub.estimated_runtime_min,
        NULL AS room_temperature,
        NULL AS humidity_percent,
        NULL AS compressor_status,
        u.status AS equipment_status,
        CASE
            WHEN u.status = 'FAULTY' OR ub.battery_health_status = 'CRITICAL' THEN 'CRITICAL'
            WHEN ub.battery_health_status IN ('POOR', 'REPLACE') THEN 'WARNING'
            ELSE 'GOOD'
        END AS health_status,
        COALESCE(ic.incident_count, 0) AS incident_count
    FROM ups u
    LEFT JOIN ups_battery ub ON ub.ups_id = u.ups_id
    LEFT JOIN (
        SELECT equipment_type, equipment_id, COUNT(*) AS incident_count
        FROM incidents
        GROUP BY equipment_type, equipment_id
    ) ic ON ic.equipment_type = 'UPS' AND ic.equipment_id = u.ups_id

    UNION ALL

    SELECT
        'COOLING',
        c.cooling_id,
        c.unit_name,
        c.asset_tag,
        CONCAT(COALESCE(c.location_room, ''), ' ', COALESCE(c.location_zone, '')),
        NULL,
        NULL,
        NULL,
        c.room_temperature,
        c.humidity_percent,
        c.compressor_status,
        c.status,
        CASE
            WHEN c.status = 'FAULTY' OR c.compressor_status = 'STOPPED' THEN 'CRITICAL'
            WHEN c.room_temperature > 28 OR c.humidity_percent > 65 THEN 'WARNING'
            ELSE 'GOOD'
        END,
        COALESCE(ic.incident_count, 0)
    FROM cooling_unit c
    LEFT JOIN (
        SELECT equipment_type, equipment_id, COUNT(*) AS incident_count
        FROM incidents
        GROUP BY equipment_type, equipment_id
    ) ic ON ic.equipment_type = 'COOLING' AND ic.equipment_id = c.cooling_id
) e;
```

### 2. Maintenance History Report
Tables: `ups_maintenance`, `cooling_maintenance`, `ups`, `cooling_unit`

```sql
SELECT m.*
FROM (
    SELECT
        'UPS' AS equipment_type,
        um.maintenance_id,
        u.ups_name AS equipment_name,
        um.maintenance_type,
        um.maintenance_date,
        um.next_due_date,
        um.technician,
        um.vendor,
        CASE WHEN um.next_due_date < CURRENT_DATE THEN 'OVERDUE' ELSE 'ON_TIME' END AS maintenance_status
    FROM ups_maintenance um
    JOIN ups u ON u.ups_id = um.ups_id

    UNION ALL

    SELECT
        'COOLING',
        cm.maintenance_id,
        c.unit_name,
        cm.maintenance_type,
        cm.maintenance_date,
        cm.next_maintenance_date AS next_due_date,
        cm.technician,
        cm.vendor,
        CASE WHEN cm.next_maintenance_date < CURRENT_DATE THEN 'OVERDUE' ELSE 'ON_TIME' END
    FROM cooling_maintenance cm
    JOIN cooling_unit c ON c.cooling_id = cm.cooling_id
) m;
```

### 3. Incident & Downtime Report
Table: `incidents` (+ `users` for technician)

```sql
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
    i.created_at
FROM incidents i
LEFT JOIN users u ON u.user_id = i.assigned_to
ORDER BY i.created_at DESC;
```

### 4. Shift Report (Per Technician)
Tables: `shift_reports`, `shift_handover_notes`, `users`

```sql
SELECT
    sr.report_id,
    COALESCE(u.full_name, u.username, 'Unknown') AS technician,
    sr.shift_type,
    sr.shift_date,
    sr.num_incidents AS incidents_handled,
    sr.downtime_duration_min,
    CONCAT('Preventive: ', COALESCE(sr.preventive_maint_done, '-'),
           ' | Corrective: ', COALESCE(sr.corrective_maint_done, '-')) AS maintenance_performed,
    shn.system_status_summary,
    shn.pending_issues,
    shn.recommendations
FROM shift_reports sr
LEFT JOIN users u ON u.user_id = sr.staff_id
LEFT JOIN shift_handover_notes shn ON shn.shift_report_id = sr.report_id;
```

### 5. Daily Consolidated Report
Table: `daily_consolidated_reports`

```sql
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
ORDER BY report_date DESC;
```

### 6. Compliance Report
Tables: `ups_maintenance`, `cooling_maintenance`, `incidents`, `alerts`

```sql
-- Overdue maintenance
SELECT 'OVERDUE_MAINTENANCE' AS issue_type, um.maintenance_id AS ref_id
FROM ups_maintenance um
WHERE um.next_due_date < CURRENT_DATE
UNION ALL
SELECT 'OVERDUE_MAINTENANCE', cm.maintenance_id
FROM cooling_maintenance cm
WHERE cm.next_maintenance_date < CURRENT_DATE;

-- SLA violations by downtime / repeated incidents
SELECT i.equipment_type, i.equipment_id, COUNT(*) AS incident_count, COALESCE(SUM(i.downtime_minutes),0) AS downtime_sum
FROM incidents i
GROUP BY i.equipment_type, i.equipment_id
HAVING COUNT(*) > 3 OR COALESCE(SUM(i.downtime_minutes),0) > 120;

-- Critical alerts
SELECT a.alert_id, a.alert_type, a.message, a.created_at
FROM alerts a
WHERE a.is_acknowledged = 0;
```

## 2) Backend Endpoints Implemented

- `GET /api/reports/equipment-health`
- `GET /api/reports/maintenance`
- `GET /api/reports/incidents`
- `GET /api/reports/shift/{id}`
- `GET /api/reports/daily`
- `GET /api/reports/compliance`
- `GET /api/reports/export?reportType=...&format=csv|pdf`

All endpoints support filter query parameters where relevant:
- `startDate`, `endDate`, `equipmentType`, `branch`, `location`, `technician`
- Optional logic parameters: `highRiskThreshold`, `downtimeThreshold`

## 3) Logic Rules Implemented

- Overdue maintenance:
  - `next_due_date < CURRENT_DATE` => `OVERDUE`
- Battery critical:
  - `battery_health_status = 'CRITICAL'` => `CRITICAL` health
- High risk equipment:
  - incident count > `highRiskThreshold` => `highRisk = true`
- Downtime:
  - uses `incidents.downtime_minutes`

## 4) Sample JSON Output (Equipment Health)

```json
{
  "reportName": "Equipment Health Report",
  "generatedAt": "2026-03-30T11:12:10",
  "filters": {
    "startDate": "2026-03-01",
    "endDate": "2026-03-30",
    "equipmentType": "UPS",
    "branch": "Kigali HQ",
    "location": "Room A",
    "technician": null,
    "highRiskThreshold": 3,
    "downtimeThreshold": 120
  },
  "rows": [
    {
      "equipmentType": "UPS",
      "equipmentId": 1,
      "equipmentName": "UPS-A1",
      "assetTag": "UPS-0001",
      "location": "Server Room A",
      "loadPercentage": 74.5,
      "batteryHealthStatus": "GOOD",
      "estimatedRuntimeMin": 42,
      "roomTemperature": null,
      "humidityPercent": null,
      "compressorStatus": null,
      "equipmentStatus": "ACTIVE",
      "healthStatus": "GOOD",
      "incidentCount": 1,
      "highRisk": false
    }
  ],
  "summary": {
    "totalEquipment": 1,
    "criticalCount": 0,
    "warningCount": 0,
    "highRiskCount": 0
  }
}
```

## 5) Sample Table Output

| equipmentType | equipmentName | loadPercentage | batteryHealthStatus | equipmentStatus | healthStatus | incidentCount | highRisk |
|---|---:|---:|---:|---:|---:|---:|---:|
| UPS | UPS-A1 | 74.5 | GOOD | ACTIVE | GOOD | 1 | false |
| COOLING | Cool-Unit-02 | - | - | ACTIVE | WARNING | 4 | true |

## 6) UI Pages Implemented

- Report Dashboard: `/compliance/reports/dashboard`
- Generate Report Page: `/compliance/reports/generate`
- Report Viewer: `/compliance/reports/viewer`

UI includes:
- Filter form
- Dynamic table rendering
- Chart.js summary chart
- Status highlighting (Good / Warning / Critical semantics)
- CSV and PDF export buttons

## 7) Optional Email Reports

The project already has mail support and alert-email infrastructure in `AlertService`.
A next-step extension can schedule a daily manager email by invoking `/api/reports/daily` and attaching generated PDF from `/api/reports/export`.
