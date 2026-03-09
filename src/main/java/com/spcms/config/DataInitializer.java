package com.spcms.config;

import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * DataInitializer: Seeds the database with a default ADMIN user on first run.
 *
 * Default credentials:
 *   Username: admin
 *   Password: admin123
 *
 * Change these credentials immediately after first login via /users.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Only seed if no admin user exists yet
        if (!userRepository.findByUsername("admin").isPresent()) {
            User admin = User.builder()
                    .username("admin")
                    .password(passwordEncoder.encode("admin123"))
                    .email("admin@spcms.local")
                    .fullName("System Administrator")
                    .role(User.Role.ADMIN)
                    .department("IT Infrastructure")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(admin);
            System.out.println("=======================================================");
            System.out.println("  SPCMS: Default admin user created.");
            System.out.println("  Username: admin  |  Password: admin123");
            System.out.println("  Please change this password immediately after login.");
            System.out.println("=======================================================");
        }

        // Seed a default Technician user as well
        if (!userRepository.findByUsername("technician").isPresent()) {
            User tech = User.builder()
                    .username("technician")
                    .password(passwordEncoder.encode("tech123"))
                    .email("tech@spcms.local")
                    .fullName("Default Technician")
                    .role(User.Role.TECHNICIAN)
                    .department("IT Infrastructure")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(tech);
        }

        // Seed a default Manager user
        if (!userRepository.findByUsername("manager").isPresent()) {
            User mgr = User.builder()
                    .username("manager")
                    .password(passwordEncoder.encode("manager123"))
                    .email("manager@spcms.local")
                    .fullName("Default Manager")
                    .role(User.Role.MANAGER)
                    .department("Operations")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(mgr);
        }
    }
}
