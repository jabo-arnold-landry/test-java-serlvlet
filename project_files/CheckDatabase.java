import java.sql.*;
import java.util.*;
public class CheckDatabase {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:mysql://localhost:3306/spcms_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String pass = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            System.out.println("SUCCESS: Connected to database");
            
            Statement stmt = conn.createStatement();
            
            // Check if users table exists and has data
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM users");
            if (rs.next()) {
                int count = rs.getInt("cnt");
                System.out.println("Users in database: " + count);
            }
            
            // Insert if needed
            String[] inserts = {
                "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('admin', '$2a$10$slYQmyNdGzin7olVN3p5aOSvzwQsPzzuTewquwC3EqLvjHF52K7W2', 'admin@spcms.com', 'Administrator', '+1-555-0001', 'ADMIN', 'IT', 'Main', 1)",
                "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('technician', '$2a$10$nOUIs5kJ7naTuTQo0kh.POLT3dr3rvA8eJ.kWrUU9xp9sKyQm7uZm', 'technician@spcms.com', 'Tech Support', '+1-555-0002', 'TECHNICIAN', 'Operations', 'Main', 1)",
                "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('manager', '$2a$10$DQv3c3eqNseaTakjQmEuJev84mYy7YqZ5KS7p12EeNMUVEUnlzhe6', 'manager@spcms.com', 'Operations Manager', '+1-555-0003', 'MANAGER', 'Management', 'Main', 1)",
                "INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('viewer', '$2a$10$VIsDenseGyggcpWQpJ3/jeLpSRy05KePV.sKyUUVXzS7v210nwiPm', 'viewer@spcms.com', 'Viewer User', '+1-555-0004', 'VIEWER', 'View Only', 'Main', 1)"
            };
            
            for (String insert : inserts) {
                try {
                    stmt.execute(insert);
                    String usr = insert.split("'")[1];
                    System.out.println("Inserted: " + usr);
                } catch (Exception e) {
                    System.out.println("Error (may be duplicate): " + e.getClass().getSimpleName());
                }
            }
            
            // Verify
            rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM users");
            if (rs.next()) {
                System.out.println("Final user count: " + rs.getInt("cnt"));
            }
            
            conn.close();
        } catch (Exception e) {
            System.out.println("ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
