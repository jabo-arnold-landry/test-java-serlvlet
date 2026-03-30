import java.sql.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestLogin {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:mysql://localhost:3306/spcms_db";
        String user = "root";
        String password = "";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, user, password);
        
        System.out.println("=== Testing BCrypt Password Matching ===\n");
        
        // Get admin user from database
        String query = "SELECT user_id, username, password, role FROM users WHERE username=?";
        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setString(1, "admin");
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            String storedHash = rs.getString("password");
            String username = rs.getString("username");
            String role = rs.getString("role");
            
            System.out.println("User: " + username);
            System.out.println("Role: " + role);
            System.out.println("Stored Hash: " + storedHash);
            System.out.println("Hash Length: " + storedHash.length());
            System.out.println();
            
            BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
            
            String[] testPasswords = {
                "admin123",
                "admin123",  // Test twice to ensure consistency
                "admin",
                "password"
            };
            
            for (String pwd : testPasswords) {
                boolean matches = encoder.matches(pwd, storedHash);
                System.out.println("Testing password '" + pwd + "': " + (matches ? "? MATCH" : "? NO MATCH"));
            }
        } else {
            System.out.println("No user found!");
        }
        
        conn.close();
    }
}
