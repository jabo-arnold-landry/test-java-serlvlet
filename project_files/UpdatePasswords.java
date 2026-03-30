import java.sql.*;

public class UpdatePasswords {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/spcms_db";
        String user = "root";
        String password = "";
        
        // These are freshly generated BCrypt hashes for the passwords
        String[][] updates = {
            {"admin", "$2a$10$d1L7Eq5kDbfDo4MBljL.6e7M01MLgJLpAH3fyDBliKhg0neOyA38S"}, 
            {"technician", "$2a$10$QrgygqYkf9dwHVMQUATr8u.PdS6rm6m6aXP1JX9h2edPqG5D14XXC"},
            {"manager", "$2a$10$K92eicnsN8YDpnyhNtTuSePWkVW5nEGQ1kqJFA2yp8uUw..3fCXkG"},
            {"viewer", "$2a$10$BOHQ6lVw2lUYFlPqe5cv/uKJeRRWub/h1Ah2bVbG/Gf0zifsLbbSG"}
        };
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            
            System.out.println("Updating user passwords with correct BCrypt hashes...\n");
            
            String updateQuery = "UPDATE users SET password = ? WHERE username = ?";
            PreparedStatement stmt = conn.prepareStatement(updateQuery);
            
            for (String[] userData : updates) {
                stmt.setString(1, userData[1]);
                stmt.setString(2, userData[0]);
                int rows = stmt.executeUpdate();
                System.out.println("? Updated " + userData[0] + ": " + rows + " row(s)");
            }
            
            // Verify updates
            System.out.println("\n=== Verification ===");
            ResultSet rs = conn.createStatement().executeQuery(
                "SELECT username, password, role FROM users ORDER BY user_id"
            );
            
            while (rs.next()) {
                System.out.printf("User: %-15s | Hash: %.60s | Role: %s\n",
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role")
                );
            }
            
            conn.close();
            System.out.println("\n? Passwords updated successfully!");
            System.out.println("\nYou can now log in with:");
            System.out.println("- admin / admin123");
            System.out.println("- technician / tech123");
            System.out.println("- manager / manager123");
            System.out.println("- viewer / viewer123");
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
