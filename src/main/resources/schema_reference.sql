-- ============================================================
-- SPCMS - SmartPower & Cooling Management System
-- Complete MySQL Schema - Team Data Contract
-- Generated: 2026-03-05
-- ============================================================

CREATE DATABASE IF NOT EXISTS spcms_db;
USE spcms_db;

-- ============================================================
-- 1. USERS & ACTIVITY LOGS
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    user_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    password        VARCHAR(255) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL,
    phone           VARCHAR(20),
    role            ENUM('ADMIN','TECHNICIAN','MANAGER','VIEWER') NOT NULL DEFAULT 'VIEWER',
    department      VARCHAR(100),
    branch          VARCHAR(100),
    is_active       BOOLEAN DEFAULT TRUE,
    last_login      DATETIME,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS activity_logs (
    log_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    action          VARCHAR(255) NOT NULL,
    entity_type     VARCHAR(50),
    entity_id       BIGINT,
    details         TEXT,
    ip_address      VARCHAR(45),
    timestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- 2. UPS MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS ups (
    ups_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    asset_tag           VARCHAR(50) UNIQUE NOT NULL,
    ups_name            VARCHAR(100) NOT NULL,
    brand               VARCHAR(50),
    model               VARCHAR(50),
    serial_number       VARCHAR(100) UNIQUE,
    capacity_kva        DECIMAL(10,2),
    phase               ENUM('SINGLE_PHASE','THREE_PHASE') DEFAULT 'SINGLE_PHASE',
    installation_date   DATE,
    location_room       VARCHAR(100),
    location_rack       VARCHAR(50),
    location_zone       VARCHAR(50),
    status              ENUM('ACTIVE','FAULTY','UNDER_MAINTENANCE','DECOMMISSIONED') DEFAULT 'ACTIVE',

    -- Electrical & Power Parameters
    input_voltage       DECIMAL(10,2),
    output_voltage      DECIMAL(10,2),
    load_percentage     DECIMAL(5,2),
    current_load_kw     DECIMAL(10,2),
    battery_voltage     DECIMAL(10,2),
    battery_current     DECIMAL(10,2),
    frequency_hz        DECIMAL(6,2),
    power_factor        DECIMAL(4,2),
    bypass_status       BOOLEAN DEFAULT FALSE,
    generator_mode      BOOLEAN DEFAULT FALSE,

    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ups_battery (
    battery_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    ups_id                  BIGINT NOT NULL,
    battery_type            VARCHAR(50),
    battery_quantity        INT,
    battery_capacity_ah     DECIMAL(10,2),
    battery_install_date    DATE,
    battery_health_status   ENUM('GOOD','FAIR','POOR','CRITICAL','REPLACE') DEFAULT 'GOOD',
    last_battery_test_date  DATE,
    estimated_runtime_min   INT,
    replacement_due_date    DATE,
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ups_id) REFERENCES ups(ups_id)
);

CREATE TABLE IF NOT EXISTS ups_maintenance (
    maintenance_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    ups_id              BIGINT NOT NULL,
    maintenance_type    ENUM('PREVENTIVE','CORRECTIVE') NOT NULL,
    maintenance_date    DATE NOT NULL,
    next_due_date       DATE,
    technician          VARCHAR(100),
    vendor              VARCHAR(100),
    spare_parts_used    TEXT,
    remarks             TEXT,
    service_report_path VARCHAR(500),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ups_id) REFERENCES ups(ups_id)
);

-- ============================================================
-- 3. COOLING MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS cooling_unit (
    cooling_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    asset_tag           VARCHAR(50) UNIQUE NOT NULL,
    unit_name           VARCHAR(100) NOT NULL,
    brand               VARCHAR(50),
    model               VARCHAR(50),
    serial_number       VARCHAR(100) UNIQUE,
    cooling_capacity_kw DECIMAL(10,2),
    installation_date   DATE,
    location_zone       VARCHAR(100),
    location_room       VARCHAR(100),
    status              ENUM('ACTIVE','FAULTY','UNDER_MAINTENANCE','DECOMMISSIONED') DEFAULT 'ACTIVE',

    -- Environmental Monitoring Parameters
    return_air_temp     DECIMAL(5,2),
    supply_air_temp     DECIMAL(5,2),
    room_temperature    DECIMAL(5,2),
    humidity_percent    DECIMAL(5,2),
    set_temperature     DECIMAL(5,2),
    set_humidity        DECIMAL(5,2),
    airflow_status      VARCHAR(50),
    cooling_mode        ENUM('AUTO','MANUAL') DEFAULT 'AUTO',
    fan_speed           VARCHAR(50),
    compressor_status   ENUM('RUNNING','STOPPED') DEFAULT 'STOPPED',

    -- Electrical & Mechanical Parameters
    input_voltage       DECIMAL(10,2),
    current_amps        DECIMAL(10,2),
    power_consumption   DECIMAL(10,2),
    refrigerant_pressure DECIMAL(10,2),
    refrigerant_type    VARCHAR(50),
    filter_status       ENUM('CLEAN','DIRTY','NEEDS_REPLACEMENT') DEFAULT 'CLEAN',
    drain_status        ENUM('CLEAR','BLOCKED') DEFAULT 'CLEAR',

    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cooling_alarm_log (
    alarm_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    cooling_id          BIGINT NOT NULL,
    alarm_type          ENUM('HIGH_TEMP','LOW_TEMP','GAS_LEAK','FAN_FAILURE','HUMIDITY_HIGH','HUMIDITY_LOW','COMPRESSOR_FAILURE') NOT NULL,
    alarm_time          DATETIME NOT NULL,
    severity            ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
    action_taken        TEXT,
    resolved_by         VARCHAR(100),
    resolution_time     DATETIME,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cooling_id) REFERENCES cooling_unit(cooling_id)
);

CREATE TABLE IF NOT EXISTS cooling_maintenance (
    maintenance_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    cooling_id          BIGINT NOT NULL,
    maintenance_type    ENUM('PREVENTIVE','CORRECTIVE') NOT NULL,
    maintenance_date    DATE NOT NULL,
    filter_cleaning_date DATE,
    gas_refill_date     DATE,
    next_maintenance_date DATE,
    technician          VARCHAR(100),
    vendor              VARCHAR(100),
    remarks             TEXT,
    service_report_path VARCHAR(500),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cooling_id) REFERENCES cooling_unit(cooling_id)
);

-- ============================================================
-- 4. MONITORING LOGS (Manual Readings for UPS & Cooling)
-- ============================================================

CREATE TABLE IF NOT EXISTS monitoring_log (
    log_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    equipment_type      ENUM('UPS','COOLING') NOT NULL,
    equipment_id        BIGINT NOT NULL,
    recorded_by         BIGINT,

    -- UPS readings
    input_voltage       DECIMAL(10,2),
    output_voltage      DECIMAL(10,2),
    battery_status      VARCHAR(50),
    load_percentage     DECIMAL(5,2),
    temperature         DECIMAL(5,2),
    runtime_remaining   INT,

    -- Cooling readings
    supply_air_temp     DECIMAL(5,2),
    return_air_temp     DECIMAL(5,2),
    humidity_percent    DECIMAL(5,2),
    cooling_performance VARCHAR(100),

    reading_time        DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes               TEXT,
    FOREIGN KEY (recorded_by) REFERENCES users(user_id)
);

-- ============================================================
-- 5. INCIDENT & FAULT MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS incidents (
    incident_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    equipment_type      ENUM('UPS','COOLING','VISITOR','OTHER') NOT NULL,
    equipment_id        BIGINT,
    title               VARCHAR(255) NOT NULL,
    description         TEXT,
    severity            ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
    status              ENUM('OPEN','IN_PROGRESS','RESOLVED','CLOSED') DEFAULT 'OPEN',
    reported_by         BIGINT,
    assigned_to         BIGINT,
    downtime_start      DATETIME,
    downtime_end        DATETIME,
    downtime_minutes    INT,
    root_cause          TEXT,
    action_taken        TEXT,
    attachment_path     VARCHAR(500),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reported_by) REFERENCES users(user_id),
    FOREIGN KEY (assigned_to) REFERENCES users(user_id)
);

-- ============================================================
-- 6. ALERT & NOTIFICATION SYSTEM
-- ============================================================

CREATE TABLE IF NOT EXISTS alerts (
    alert_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    alert_type          ENUM('HIGH_TEMP','LOW_BATTERY','UPS_OVERLOAD','HUMIDITY','MAINTENANCE_DUE','EQUIPMENT_FAULT') NOT NULL,
    equipment_type      ENUM('UPS','COOLING','OTHER') NOT NULL,
    equipment_id        BIGINT,
    message             TEXT NOT NULL,
    threshold_value     DECIMAL(10,2),
    actual_value        DECIMAL(10,2),
    is_sent             BOOLEAN DEFAULT FALSE,
    is_acknowledged     BOOLEAN DEFAULT FALSE,
    acknowledged_by     BIGINT,
    acknowledged_at     DATETIME,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (acknowledged_by) REFERENCES users(user_id)
);

-- ============================================================
-- 7. DATA CENTER EQUIPMENT RECORD
-- ============================================================

CREATE TABLE IF NOT EXISTS equipment (
    equipment_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    asset_tag_number        VARCHAR(50) UNIQUE NOT NULL,
    equipment_name          VARCHAR(100) NOT NULL,
    equipment_type          VARCHAR(50),
    brand_manufacturer      VARCHAR(100),
    model_number            VARCHAR(50),
    serial_number           VARCHAR(100) UNIQUE,
    hostname                VARCHAR(100),
    ip_address              VARCHAR(45),
    mac_address             VARCHAR(50),

    -- Location Information
    data_center_name        VARCHAR(100),
    room_name               VARCHAR(100),
    rack_number             VARCHAR(50),
    rack_unit_position      VARCHAR(20),
    physical_location       VARCHAR(200),

    -- Technical Specifications
    cpu_type                VARCHAR(100),
    ram_size                VARCHAR(50),
    storage_capacity        VARCHAR(50),
    power_rating            VARCHAR(50),
    firmware_version        VARCHAR(50),
    operating_system        VARCHAR(100),
    network_ports_count     INT,
    vlan_assignment         VARCHAR(50),

    -- Procurement Information
    purchase_date           DATE,
    supplier_name           VARCHAR(100),
    purchase_order_number   VARCHAR(50),
    invoice_number          VARCHAR(50),
    warranty_start_date     DATE,
    warranty_expiry_date    DATE,
    cost                    DECIMAL(12,2),
    funding_source          VARCHAR(100),

    -- Maintenance & Support
    maintenance_status      ENUM('ACTIVE','FAULTY','UNDER_REPAIR','DECOMMISSIONED') DEFAULT 'ACTIVE',
    last_maintenance_date   DATE,
    next_maintenance_due    DATE,
    maintenance_type        ENUM('PREVENTIVE','CORRECTIVE'),
    support_vendor          VARCHAR(100),
    amc_contract_details    TEXT,
    spare_parts_availability TEXT,
    incident_history        TEXT,

    -- Power & Environmental Monitoring
    power_source            VARCHAR(100),
    connected_pdu           VARCHAR(50),
    temperature_range       VARCHAR(50),
    humidity_level          VARCHAR(50),
    power_consumption       DECIMAL(10,2),
    cooling_zone            VARCHAR(50),

    -- Lifecycle Management
    installation_date       DATE,
    commissioning_date      DATE,
    end_of_life             DATE,
    end_of_support          DATE,
    disposal_date           DATE,
    disposal_method         VARCHAR(100),
    reason_for_decommission TEXT,

    -- Documentation & Attachments
    config_file_path        VARCHAR(500),
    network_diagram_ref     VARCHAR(500),
    rack_layout_diagram     VARCHAR(500),
    maintenance_report_path VARCHAR(500),
    photos_path             VARCHAR(500),

    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- 8. VISITOR MANAGEMENT SYSTEM (VMS)
-- ============================================================

CREATE TABLE IF NOT EXISTS visitors (
    visitor_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name           VARCHAR(100) NOT NULL,
    national_id_passport VARCHAR(50) NOT NULL,
    company             VARCHAR(100),
    phone               VARCHAR(20),
    purpose_of_visit    TEXT NOT NULL,
    host_employee_id    BIGINT,
    equipment_carried   TEXT,
    id_copy_path        VARCHAR(500),
    photo_path          VARCHAR(500),
    pass_number         VARCHAR(50) UNIQUE,
    visit_date          DATE NOT NULL,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (host_employee_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS visit_approvals (
    approval_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    visitor_id          BIGINT NOT NULL,
    approved_by         BIGINT,
    status              ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
    decision_time       DATETIME,
    remarks             TEXT,
    notification_sent   BOOLEAN DEFAULT FALSE,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS visitor_check_in_out (
    check_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    visitor_id          BIGINT NOT NULL,
    check_in_time       DATETIME,
    check_out_time      DATETIME,
    temporary_badge     VARCHAR(50),
    escort_id           BIGINT,
    equipment_confirmed_out BOOLEAN DEFAULT FALSE,
    visit_closed        BOOLEAN DEFAULT FALSE,
    remarks             TEXT,
    FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id),
    FOREIGN KEY (escort_id) REFERENCES users(user_id)
);

-- ============================================================
-- 9. SHIFT & DAILY REPORTS
-- ============================================================

CREATE TABLE IF NOT EXISTS shift_reports (
    report_id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    staff_id                BIGINT NOT NULL,
    shift_type              ENUM('MORNING','EVENING','NIGHT') NOT NULL,
    shift_date              DATE NOT NULL,
    login_time              DATETIME,
    logout_time             DATETIME,

    -- UPS Monitoring Summary
    avg_input_voltage       DECIMAL(10,2),
    avg_output_voltage      DECIMAL(10,2),
    max_load_percent        DECIMAL(5,2),
    min_battery_level       DECIMAL(5,2),
    battery_runtime_remaining INT,
    overload_occurred       BOOLEAN DEFAULT FALSE,
    bypass_activated        BOOLEAN DEFAULT FALSE,

    -- Cooling Monitoring Summary
    highest_temp_recorded   DECIMAL(5,2),
    lowest_temp_recorded    DECIMAL(5,2),
    avg_humidity            DECIMAL(5,2),
    compressor_status       VARCHAR(50),
    fan_status              VARCHAR(50),
    high_temp_alarm         BOOLEAN DEFAULT FALSE,
    humidity_alarm          BOOLEAN DEFAULT FALSE,

    -- Incidents During Shift
    num_incidents           INT DEFAULT 0,
    critical_incidents      INT DEFAULT 0,
    downtime_duration_min   INT DEFAULT 0,
    root_cause_summary      TEXT,
    action_taken            TEXT,

    -- Maintenance Activities Done
    preventive_maint_done   TEXT,
    corrective_maint_done   TEXT,
    spare_parts_used        TEXT,
    photos_uploaded_path    VARCHAR(500),

    -- Visitor Log During Shift
    num_visitors            INT DEFAULT 0,
    visitor_approved_by     VARCHAR(100),
    escort_name             VARCHAR(100),
    visit_duration_summary  TEXT,
    visitor_incident        TEXT,

    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS shift_handover_notes (
    note_id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    shift_report_id         BIGINT NOT NULL,
    system_status_summary   TEXT NOT NULL,
    pending_issues          TEXT,
    recommendations         TEXT,
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shift_report_id) REFERENCES shift_reports(report_id)
);

CREATE TABLE IF NOT EXISTS daily_consolidated_reports (
    report_id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    report_date             DATE NOT NULL UNIQUE,

    -- Overall UPS Health
    avg_daily_load          DECIMAL(10,2),
    total_ups_alarms        INT DEFAULT 0,
    battery_status_summary  TEXT,
    failover_to_generator   BOOLEAN DEFAULT FALSE,

    -- Cooling Performance
    avg_room_temperature    DECIMAL(5,2),
    highest_temp_recorded   DECIMAL(5,2),
    humidity_stability      VARCHAR(100),
    cooling_failure         BOOLEAN DEFAULT FALSE,

    -- Incidents Summary
    total_incidents         INT DEFAULT 0,
    total_downtime_min      INT DEFAULT 0,
    mttr_minutes            DECIMAL(10,2),
    mtbf_hours              DECIMAL(10,2),

    -- Maintenance Summary
    maintenance_performed   TEXT,
    overdue_maintenance     TEXT,

    -- Visitor Summary
    total_visitors          INT DEFAULT 0,
    overstayed_visitors     INT DEFAULT 0,
    high_risk_visits        INT DEFAULT 0,

    generated_at            DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_activity_user ON activity_logs(user_id);
CREATE INDEX idx_activity_time ON activity_logs(timestamp);
CREATE INDEX idx_ups_status ON ups(status);
CREATE INDEX idx_cooling_status ON cooling_unit(status);
CREATE INDEX idx_monitoring_type ON monitoring_log(equipment_type, equipment_id);
CREATE INDEX idx_monitoring_time ON monitoring_log(reading_time);
CREATE INDEX idx_incident_status ON incidents(status);
CREATE INDEX idx_incident_severity ON incidents(severity);
CREATE INDEX idx_alert_type ON alerts(alert_type);
CREATE INDEX idx_alert_sent ON alerts(is_sent);
CREATE INDEX idx_visitor_date ON visitors(visit_date);
CREATE INDEX idx_shift_date ON shift_reports(shift_date);
CREATE INDEX idx_daily_date ON daily_consolidated_reports(report_date);
CREATE INDEX idx_equipment_status ON equipment(maintenance_status);
