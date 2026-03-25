package com.spcms.services;

import com.spcms.models.User;
import com.spcms.models.ActivityLog;
import com.spcms.repositories.UserRepository;
import com.spcms.repositories.ActivityLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ActivityLogRepository activityLogRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ==================== CRUD ====================

    public User createUser(User user) {
        return createUser(user, null);
    }

    public User createUser(User user, String ipAddress) {
        // Hash the password before saving; only hash if not already hashed
        if (user.getPassword() != null && !user.getPassword().startsWith("$2a$")) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        User saved = userRepository.save(user);
        logActivity(saved.getUserId(), "CREATE_USER", "User", saved.getUserId(),
                "Created user: " + saved.getUsername(), ipAddress);
        return saved;
    }

    public User updateUser(User user) {
        return updateUser(user, null);
    }

    public User updateUser(User user, String ipAddress) {
        // Only re-hash if the password field was changed (doesn't look like a bcrypt hash)
        if (user.getPassword() != null && !user.getPassword().startsWith("$2a$")) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        User updated = userRepository.save(user);
        logActivity(updated.getUserId(), "UPDATE_USER", "User", updated.getUserId(),
                "Updated user: " + updated.getUsername(), ipAddress);
        return updated;
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public List<User> getUsersByRole(User.Role role) {
        return userRepository.findByRole(role);
    }

    public List<User> getActiveUsers() {
        return userRepository.findByIsActiveTrue();
    }


    public void deactivateUser(Long userId) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setIsActive(false);
            userRepository.save(user);
            logActivity(userId, "DEACTIVATE_USER", "User", userId,
                    "Deactivated user: " + user.getUsername());
        });
    }

    public void reactivateUser(Long userId) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setIsActive(true);
            userRepository.save(user);
            logActivity(userId, "REACTIVATE_USER", "User", userId,
                    "Reactivated user: " + user.getUsername());
        });
    }

    public void deleteUser(Long userId) {
        activityLogRepository.deleteByUser_UserId(userId);
        userRepository.deleteById(userId);
    }

    // ==================== Role Management ====================

    public void assignRole(Long userId, User.Role role) {
        userRepository.findById(userId).ifPresent(user -> {
            User.Role oldRole = user.getRole();
            user.setRole(role);
            userRepository.save(user);
            logActivity(userId, "CHANGE_ROLE", "User", userId,
                    "Role changed from " + oldRole + " to " + role);
        });
    }

    // ==================== Authentication Helpers ====================

    public void recordLogin(Long userId) {
        recordLogin(userId, null);
    }

    public void recordLogin(Long userId, String ipAddress) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setLastLogin(LocalDateTime.now());
            userRepository.save(user);
            logActivity(userId, "LOGIN", "User", userId, "User logged in", ipAddress);
        });
    }

    // ==================== Activity Logging ====================

    public void logActivity(Long userId, String action, String entityType,
                            Long entityId, String details) {
        logActivity(userId, action, entityType, entityId, details, null);
    }

    public void logActivity(Long userId, String action, String entityType,
                            Long entityId, String details, String ipAddress) {
        ActivityLog log = ActivityLog.builder()
                .user(userRepository.findById(userId).orElse(null))
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .details(details)
                .ipAddress(ipAddress)
                .build();
        activityLogRepository.save(log);
    }

    public List<ActivityLog> getUserActivityLogs(Long userId) {
        return activityLogRepository.findByUser_UserIdOrderByTimestampDesc(userId);
    }

    public List<ActivityLog> getActivityLogsByDateRange(LocalDateTime start, LocalDateTime end) {
        return activityLogRepository.findByTimestampBetweenOrderByTimestampDesc(start, end);
    }
}
