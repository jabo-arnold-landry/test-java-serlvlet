package com.spcms.services;

import com.spcms.models.ActivityLog;
import com.spcms.models.User;
import com.spcms.repositories.ActivityLogRepository;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for retrieving and filtering maintenance history logs
 * from the activity_logs table.
 */
@Service
@Transactional(readOnly = true)
public class MaintenanceHistoryService {

    @Autowired
    private ActivityLogRepository logRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Get filtered maintenance history logs.
     * Filters by equipment type (MAINTENANCE entity types), action, user, and date range.
     */
    public List<ActivityLog> getFilteredHistory(String equipmentType, String action,
                                                 Long userId, LocalDateTime start, LocalDateTime end) {
        // Determine the entity type filter pattern
        String entityTypePattern = "MAINTENANCE";
        if ("UPS".equals(equipmentType)) {
            entityTypePattern = "UPS_MAINTENANCE";
        } else if ("COOLING".equals(equipmentType)) {
            entityTypePattern = "COOLING_MAINTENANCE";
        }

        boolean hasAction = action != null && !action.isBlank();
        boolean hasUser = userId != null && userId > 0;

        if (hasAction && hasUser) {
            return logRepository.findMaintenanceLogsFull(entityTypePattern, action, userId, start, end);
        } else if (hasAction) {
            return logRepository.findMaintenanceLogsByAction(entityTypePattern, action, start, end);
        } else if (hasUser) {
            return logRepository.findMaintenanceLogsByUser(entityTypePattern, userId, start, end);
        } else {
            return logRepository.findMaintenanceLogs(entityTypePattern, start, end);
        }
    }

    /**
     * Get all distinct action types used in maintenance logs.
     */
    public List<String> getDistinctActions() {
        return logRepository.findDistinctMaintenanceActions();
    }

    /**
     * Get all active users for the filter dropdown.
     */
    public List<User> getAllActiveUsers() {
        return userRepository.findByIsActiveTrue();
    }
}
