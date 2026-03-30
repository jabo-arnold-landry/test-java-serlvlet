import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class GenerateHashes {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        String[][] users = {
            {"admin", "admin123", "ADMIN"},
            {"technician", "tech123", "TECHNICIAN"},
            {"manager", "manager123", "MANAGER"},
            {"viewer", "viewer123", "VIEWER"}
        };
        
        System.out.println("=== BCrypt Hash Generation ===\n");
        System.out.println("Username    | Password         | BCrypt Hash");
        System.out.println("============================================");
        
        for (String[] user : users) {
            String hash = encoder.encode(user[1]);
            System.out.printf("%-11s | %-16s | %s\n", user[0], user[1], hash);
        }
        
        System.out.println("\n=== SQL INSERT Statements ===\n");
        for (String[] user : users) {
            String hash = encoder.encode(user[1]);
            String email = user[0] + "@spcms.com";
            String fullName = user[0].substring(0, 1).toUpperCase() + user[0].substring(1) + " User";
            System.out.printf("INSERT INTO users (username, password, email, full_name, phone, role, department, branch, is_active) VALUES ('%s', '%s', '%s', '%s', '+1-555-000', '%s', 'Dept', 'Main', true);\n",
                user[0], hash, email, fullName, user[2]);
        }
    }
}
