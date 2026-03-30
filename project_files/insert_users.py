import mysql.connector
from mysql.connector import Error

try:
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='spcms_db'
    )
    
    if connection.is_connected():
        print("✓ Database connection successful!")
        cursor = connection.cursor()
        
        users = [
            ("INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) "
             "VALUES ('admin', '\$2a\$10\$slYQmyNdGzin7olVN3p5aOSvzwQsPzzuTewquwC3EqLvjHF52K7W2', 'admin@spcms.com', 'Administrator', '+1-555-0001', 'ADMIN', 'IT', 'Main', true) "
             "ON DUPLICATE KEY UPDATE password = VALUES(password)", "admin"),
            ("INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) "
             "VALUES ('technician', '\$2a\$10\$nOUIs5kJ7naTuTQo0kh.POLT3dr3rvA8eJ.kWrUU9xp9sKyQm7uZm', 'technician@spcms.com', 'Tech Support', '+1-555-0002', 'TECHNICIAN', 'Operations', 'Main', true) "
             "ON DUPLICATE KEY UPDATE password = VALUES(password)", "technician"),
            ("INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) "
             "VALUES ('manager', '\$2a\$10\$DQv3c3eqNseaTakjQmEuJev84mYy7YqZ5KS7p12EeNMUVEUnlzhe6', 'manager@spcms.com', 'Operations Manager', '+1-555-0003', 'MANAGER', 'Management', 'Main', true) "
             "ON DUPLICATE KEY UPDATE password = VALUES(password)", "manager"),
            ("INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) "
             "VALUES ('viewer', '\$2a\$10\$VIsDenseGyggcpWQpJ3/jeLpSRy05KePV.sKyUUVXzS7v210nwiPm', 'viewer@spcms.com', 'Viewer User', '+1-555-0004', 'VIEWER', 'View Only', 'Main', true) "
             "ON DUPLICATE KEY UPDATE password = VALUES(password)", "viewer")
        ]
        
        for sql, username in users:
            try:
                cursor.execute(sql)
                connection.commit()
                print(f"✓ Inserted user: {username}")
            except Error as e:
                print(f"✗ Error inserting {username}: {e}")
        
        # Verify
        query = "SELECT user_id, username, email, role, is_active FROM users ORDER BY user_id"
        cursor.execute(query)
        results = cursor.fetchall()
        
        print("\n--- Verification ---")
        for row in results:
            print(f"ID: {row[0]:2d} | Username: {row[1]:15s} | Role: {row[3]:12s} | Active: {row[4]}")
        
        print("\n✓ Test users inserted successfully!")
        print("\nTest Credentials:")
        print("─────────────────────────────────────")
        print("admin      | Password: admin123    | Role: ADMIN")
        print("technician | Password: tech123     | Role: TECHNICIAN")
        print("manager    | Password: manager123  | Role: MANAGER")
        print("viewer     | Password: viewer123   | Role: VIEWER")
        
except Error as e:
    print(f"✗ Database error: {e}")
except Exception as e:
    print(f"✗ Error: {e}")
