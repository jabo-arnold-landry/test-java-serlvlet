package com.spcms.config;

import com.spcms.models.MonitoringLog;
import com.spcms.models.User;
import com.spcms.repositories.MonitoringLogRepository;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

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

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

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

                // Seed sample monitoring logs for demo/report screenshots when table is empty.
                if (monitoringLogRepository.count() == 0) {
                    MonitoringLog upsReading = MonitoringLog.builder()
                        .equipmentType(MonitoringLog.EquipmentType.UPS)
                        .equipmentId(101L)
                        .inputVoltage(new BigDecimal("230.00"))
                        .outputVoltage(new BigDecimal("229.80"))
                        .loadPercentage(new BigDecimal("62.60"))
                        .temperature(new BigDecimal("27.80"))
                        .batteryStatus("NORMAL")
                        .runtimeRemaining(45)
                        .notes("Auto-seeded UPS sample reading")
                        .readingTime(LocalDateTime.now().minusMinutes(15))
                        .build();

                    MonitoringLog coolingReading = MonitoringLog.builder()
                        .equipmentType(MonitoringLog.EquipmentType.COOLING)
                        .equipmentId(201L)
                        .returnAirTemp(new BigDecimal("24.50"))
                        .supplyAirTemp(new BigDecimal("19.80"))
                        .humidityPercent(new BigDecimal("47.00"))
                        .coolingPerformance("STABLE")
                        .notes("Auto-seeded cooling sample reading")
                        .readingTime(LocalDateTime.now().minusMinutes(10))
                        .build();

                    MonitoringLog upsWarningReading = MonitoringLog.builder()
                        .equipmentType(MonitoringLog.EquipmentType.UPS)
                        .equipmentId(103L)
                        .inputVoltage(new BigDecimal("228.40"))
                        .outputVoltage(new BigDecimal("227.90"))
                        .loadPercentage(new BigDecimal("84.10"))
                        .temperature(new BigDecimal("30.20"))
                        .batteryStatus("LOW")
                        .runtimeRemaining(18)
                        .notes("Auto-seeded UPS high-load sample")
                        .readingTime(LocalDateTime.now().minusMinutes(5))
                        .build();

                    monitoringLogRepository.saveAll(List.of(upsReading, coolingReading, upsWarningReading));
                    System.out.println("SPCMS: Seeded sample monitoring logs.");
                }
    }
}
