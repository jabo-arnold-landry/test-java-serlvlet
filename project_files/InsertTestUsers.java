import java.sql.*;

public class InsertTestUsers {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/spcms_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String username = "root";
        String password = "";
        
        String[] users = {
            "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('admin', '$2a$10$slYQmyNdGzin7olVN3p5aOSvzwQsPzzuTewquwC3EqLvjHF52K7W2', 'admin@spcms.com', 'Administrator', '+1-555-0001', 'ADMIN', 'IT', 'Main', true) ON DUPLICATE KEY UPDATE password = VALUES(password);",
            "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('technician', '$2a$10$nOUIs5kJ7naTuTQo0kh.POLT3dr3rvA8eJ.kWrUU9xp9sKyQm7uZm', 'technician@spcms.com', 'Tech Support', '+1-555-0002', 'TECHNICIAN', 'Operations', 'Main', true) ON DUPLICATE KEY UPDATE password = VALUES(password);",
            "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('manager', '$2a$10$DQv3c3eqNseaTakjQmEuJev84mYy7YqZ5KS7p12EeNMUVEUnlzhe6', 'manager@spcms.com', 'Operations Manager', '+1-555-0003', 'MANAGER', 'Management', 'Main', true) ON DUPLICATE KEY UPDATE password = VALUES(password);",
            "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('viewer', '$2a$10$VIsDenseGyggcpWQpJ3/jeLpSRy05KePV.sKyUUVXzS7v210nwiPm', 'viewer@spcms.com', 'Viewer User', '+1-555-0004', 'VIEWER', 'View Only', 'Main', true) ON DUPLICATE KEY UPDATE password = VALUES(password);"
        };
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            try (Connection conn = DriverManager.getConnection(url, username, password)) {
                System.out.println("✓ Database connection successful!");
                System.out.println("Database: spcms_db");
                System.out.println("Host: localhost:3306");
                System.out.println();
                
                Statement stmt = conn.createStatement();
                
                for (String insertSQL : users) {
                    try {
                        stmt.execute(insertSQL);
                        String usernameFromSQL = insertSQL.split("'")[1];
                        System.out.println("✓ Inserted user: " + usernameFromSQL);
                    } catch (SQLException e) {
                        System.err.println("✗ Error inserting user: " + e.getMessage());
                    }
                }
                
                // Verify insertion
                System.out.println("\n--- Verification ---");
                ResultSet rs = stmt.executeQuery("SELECT user_id, username, email, role, is_active FROM users ORDER BY user_id;");
                while (rs.next()) {
                    System.out.printf("ID: %d | Username: %-15s | Role: %-12s | Active: %s\n", 
                        rs.getLong("user_id"), 
                        rs.getString("username"), 
                        rs.getString("role"),
                        rs.getBoolean("is_active")
                    );
                }
                
                System.out.println("\n✓ Test users inserted successfully!");
                System.out.println("\nTest Credentials:");
                System.out.println("─────────────────────────────────────");
                System.out.println("admin      | Password: admin123    | Role: ADMIN");
                System.out.println("technician | Password: tech123     | Role: TECHNICIAN");
                System.out.println("manager    | Password: manager123  | Role: MANAGER");
                System.out.println("viewer     | Password: viewer123   | Role: VIEWER");
                
            } catch (SQLException e) {
                System.err.println("✗ Database error: " + e.getMessage());
                e.printStackTrace();
            }
        } catch (ClassNotFoundException e) {
            System.err.println("✗ MySQL JDBC Driver not found: " + e.getMessage());
        }
    }
}
