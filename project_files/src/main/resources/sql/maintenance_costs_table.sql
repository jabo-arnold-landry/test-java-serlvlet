-- ============================================================
-- SPCMS: Maintenance Costs Table
-- Tracks individual cost entries for UPS & Cooling maintenance
-- ============================================================

CREATE TABLE IF NOT EXISTS maintenance_costs (
    cost_id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    maintenance_id     BIGINT NOT NULL,
    equipment_type     VARCHAR(10) NOT NULL,
    cost_amount        DECIMAL(12,2) NOT NULL,
    cost_description   TEXT,
    recorded_at        DATETIME DEFAULT CURRENT_TIMESTAMP
);
