#!/bin/bash
# Simple script to verify database and insert users

# MySQL connection details
MYSQL_USER="root"
MYSQL_PASS=""
DATABASE="spcms_db"

# Check if database exists
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "USE $DATABASE; SHOW TABLES LIKE 'users';" 2>/dev/null

# Insert test users
mysql -u $MYSQL_USER -p$MYSQL_PASS $DATABASE << EOF
-- Insert test users
INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) 
VALUES ('admin', '\$2a\$10\$slYQmyNdGzin7olVN3p5aOSvzwQsPzzuTewquwC3EqLvjHF52K7W2', 'admin@spcms.com', 'Administrator', '+1-555-0001', 'ADMIN', 'IT', 'Main', 1)
ON DUPLICATE KEY UPDATE password = VALUES(password);

INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) 
VALUES ('technician', '\$2a\$10\$nOUIs5kJ7naTuTQo0kh.POLT3dr3rvA8eJ.kWrUU9xp9sKyQm7uZm', 'technician@spcms.com', 'Tech Support', '+1-555-0002', 'TECHNICIAN', 'Operations', 'Main', 1)
ON DUPLICATE KEY UPDATE password = VALUES(password);

INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) 
VALUES ('manager', '\$2a\$10\$DQv3c3eqNseaTakjQmEuJev84mYy7YqZ5KS7p12EeNMUVEUnlzhe6', 'manager@spcms.com', 'Operations Manager', '+1-555-0003', 'MANAGER', 'Management', 'Main', 1)
ON DUPLICATE KEY UPDATE password = VALUES(password);

INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) 
VALUES ('viewer', '\$2a\$10\$VIsDenseGyggcpWQpJ3/jeLpSRy05KePV.sKyUUVXzS7v210nwiPm', 'viewer@spcms.com', 'Viewer User', '+1-555-0004', 'VIEWER', 'View Only', 'Main', 1)
ON DUPLICATE KEY UPDATE password = VALUES(password);

-- Verify insertion
SELECT user_id, username, email, role, is_active FROM users ORDER BY user_id;
EOF
