package com.spcms.config;

import com.spcms.services.UserService;
import com.spcms.services.AlertService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAttributes {

    private static final Logger log = LoggerFactory.getLogger(GlobalModelAttributes.class);

    @Autowired
    private AlertService alertService;

    @Autowired
    private UserService userService;

    @ModelAttribute("unacknowledgedAlerts")
    public int unacknowledgedAlerts(Authentication authentication) {
        try {
            if (authentication == null || authentication.getName() == null) {
                return 0;
            }
            Long userId = userService.getUserByUsername(authentication.getName())
                    .map(com.spcms.models.User::getUserId)
                    .orElse(null);
            return Math.toIntExact(alertService.countUnacknowledgedAlertsForUser(userId));
        } catch (Exception e) {
            log.warn("Could not fetch unacknowledged alerts count: {}", e.getMessage());
            return 0;
        }
    }
}
