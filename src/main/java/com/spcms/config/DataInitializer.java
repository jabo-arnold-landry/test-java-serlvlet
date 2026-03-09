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

        // ============== ADDITIONAL TEST USERS ==============

        // Additional Admins
        if (!userRepository.findByUsername("sarah.admin").isPresent()) {
            userRepository.save(User.builder()
                    .username("sarah.admin")
                    .password(passwordEncoder.encode("password123"))
                    .email("sarah.johnson@spcms.local")
                    .fullName("Sarah Johnson")
                    .phone("+250788111222")
                    .role(User.Role.ADMIN)
                    .department("IT Infrastructure")
                    .branch("Backup Data Center")
                    .isActive(true)
                    .build());
        }

        // Additional Technicians
        if (!userRepository.findByUsername("john.tech").isPresent()) {
            userRepository.save(User.builder()
                    .username("john.tech")
                    .password(passwordEncoder.encode("password123"))
                    .email("john.doe@spcms.local")
                    .fullName("John Doe")
                    .phone("+250788222333")
                    .role(User.Role.TECHNICIAN)
                    .department("Cooling Systems")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build());
        }

        if (!userRepository.findByUsername("mike.tech").isPresent()) {
            userRepository.save(User.builder()
                    .username("mike.tech")
                    .password(passwordEncoder.encode("password123"))
                    .email("mike.wilson@spcms.local")
                    .fullName("Mike Wilson")
                    .phone("+250788333444")
                    .role(User.Role.TECHNICIAN)
                    .department("Power Systems")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build());
        }

        if (!userRepository.findByUsername("emma.tech").isPresent()) {
            userRepository.save(User.builder()
                    .username("emma.tech")
                    .password(passwordEncoder.encode("password123"))
                    .email("emma.brown@spcms.local")
                    .fullName("Emma Brown")
                    .phone("+250788444555")
                    .role(User.Role.TECHNICIAN)
                    .department("UPS Maintenance")
                    .branch("Backup Data Center")
                    .isActive(true)
                    .build());
        }

        // Additional Managers
        if (!userRepository.findByUsername("david.mgr").isPresent()) {
            userRepository.save(User.builder()
                    .username("david.mgr")
                    .password(passwordEncoder.encode("password123"))
                    .email("david.smith@spcms.local")
                    .fullName("David Smith")
                    .phone("+250788555666")
                    .role(User.Role.MANAGER)
                    .department("Facilities Management")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build());
        }

        if (!userRepository.findByUsername("lisa.mgr").isPresent()) {
            userRepository.save(User.builder()
                    .username("lisa.mgr")
                    .password(passwordEncoder.encode("password123"))
                    .email("lisa.anderson@spcms.local")
                    .fullName("Lisa Anderson")
                    .phone("+250788666777")
                    .role(User.Role.MANAGER)
                    .department("Security Operations")
                    .branch("Backup Data Center")
                    .isActive(true)
                    .build());
        }

        // Viewers (read-only users)
        if (!userRepository.findByUsername("viewer1").isPresent()) {
            userRepository.save(User.builder()
                    .username("viewer1")
                    .password(passwordEncoder.encode("password123"))
                    .email("viewer1@spcms.local")
                    .fullName("Alex Viewer")
                    .phone("+250788777888")
                    .role(User.Role.VIEWER)
                    .department("External Audit")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build());
        }

        if (!userRepository.findByUsername("viewer2").isPresent()) {
            userRepository.save(User.builder()
                    .username("viewer2")
                    .password(passwordEncoder.encode("password123"))
                    .email("viewer2@spcms.local")
                    .fullName("Chris Monitor")
                    .phone("+250788888999")
                    .role(User.Role.VIEWER)
                    .department("Compliance")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build());
        }

        // Inactive user for testing
        if (!userRepository.findByUsername("inactive.user").isPresent()) {
            userRepository.save(User.builder()
                    .username("inactive.user")
                    .password(passwordEncoder.encode("password123"))
                    .email("inactive@spcms.local")
                    .fullName("Inactive User")
                    .phone("+250788999000")
                    .role(User.Role.TECHNICIAN)
                    .department("IT Infrastructure")
                    .branch("Main Data Center")
                    .isActive(false)
                    .build());
        }

        System.out.println("=======================================================");
        System.out.println("  SPCMS: Test users seeded successfully.");
        System.out.println("  All test users password: password123");
        System.out.println("=======================================================");
    }
}
