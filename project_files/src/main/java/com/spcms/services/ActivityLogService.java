package com.spcms.services;

import com.spcms.models.ActivityLog;
import com.spcms.models.User;
import com.spcms.repositories.ActivityLogRepository;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.servlet.http.HttpServletRequest;

@Service
@Transactional
public class ActivityLogService {

    @Autowired
    private ActivityLogRepository activityLogRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Log an activity performed by the currently authenticated user.
     */
    public void log(String action, String entityType, Long entityId, String details, HttpServletRequest request) {
        User user = getCurrentUser();
        if (user == null) return;

        ActivityLog log = ActivityLog.builder()
                .user(user)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .details(details)
                .ipAddress(request != null ? request.getRemoteAddr() : "unknown")
                .build();

        activityLogRepository.save(log);
    }

    /**
     * Convenience overload without HttpServletRequest.
     */
    public void log(String action, String entityType, Long entityId, String details) {
        log(action, entityType, entityId, details, null);
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        String username = auth.getName();
        return userRepository.findByUsername(username).orElse(null);
    }
}
