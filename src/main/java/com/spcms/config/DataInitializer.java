package com.spcms.config;

import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private com.spcms.repositories.UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

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
    }
}
