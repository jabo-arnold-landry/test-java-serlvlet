import java.sql.*;

public class VerifyUsers {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/spcms_db";
        String user = "root";
        String password = "";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            
            System.out.println("Connected to database");
            
            String query = "SELECT user_id, username, password, role, is_active FROM users ORDER BY user_id";
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();
            
            System.out.println("ID | Username | Password Hash | Role | Active");
            System.out.println("========================================================================");
            
            while (rs.next()) {
                System.out.printf("%d | %s | %s | %s | %s\n",
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role"),
                    rs.getBoolean("is_active")
                );
            }
            
            conn.close();
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
