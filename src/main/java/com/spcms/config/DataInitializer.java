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
import java.util.Optional;

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
    private com.spcms.repositories.UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

    @Autowired
    private com.spcms.repositories.VisitorRepository visitorRepository;

    @Autowired
    private com.spcms.repositories.VisitApprovalRepository visitApprovalRepository;

    @Autowired
    private com.spcms.repositories.VisitorCheckInOutRepository visitorCheckInOutRepository;

    @Override
    public void run(String... args) throws Exception {
        try {
            cleanupDeprecatedViewers();
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to cleanup deprecated viewers, but continuing startup: " + e.getMessage());
            e.printStackTrace();
        }

        // 2. Create default security user if it doesn't exist
        ensureSecurityUserExists();
    }

    private void cleanupDeprecatedViewers() {
        // 1. Delete all viewers as visitors no longer have self-service accounts
        java.util.List<User> viewers = userRepository.findByRole(User.Role.VIEWER);
        if (!viewers.isEmpty()) {
            System.out.println("Initiating cleanup for " + viewers.size() + " deprecated VIEWER accounts...");
            for (User viewer : viewers) {
                Long userId = viewer.getUserId();
                
                // Find all visitors requested by this viewer
                java.util.List<com.spcms.models.Visitor> visitors = visitorRepository.findByRequestedBy_UserId(userId);
                for (com.spcms.models.Visitor visitor : visitors) {
                    // Delete check-in/out records
                    java.util.List<com.spcms.models.VisitorCheckInOut> checks = visitorCheckInOutRepository.findByVisitor_VisitorId(visitor.getVisitorId());
                    visitorCheckInOutRepository.deleteAll(checks);
                    
                    // Delete approvals
                    java.util.List<com.spcms.models.VisitApproval> approvals = visitApprovalRepository.findByVisitor_VisitorId(visitor.getVisitorId());
                    visitApprovalRepository.deleteAll(approvals);
                    
                    // Delete the visitor
                    visitorRepository.delete(visitor);
                }
                
                // Finally delete the user
                userRepository.delete(viewer);
            }
            System.out.println("VIEWER account cleanup completed.");
        }
    }

    private void ensureSecurityUserExists() {
        Optional<User> securityUser = userRepository.findByUsername("security");
        if (securityUser.isEmpty()) {
            User user = User.builder()
                    .username("security")
                    .password(passwordEncoder.encode("sec123"))
                    .email("security@spcms.com")
                    .fullName("Systems Security")
                    .role(User.Role.SECURITY)
                    .isActive(true)
                    .build();
            userRepository.save(user);
            System.out.println("Default security user created: security / sec123");
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
