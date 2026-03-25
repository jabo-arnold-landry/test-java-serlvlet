package com.spcms.config;

import com.spcms.services.AlertService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAttributes {

    private static final Logger log = LoggerFactory.getLogger(GlobalModelAttributes.class);

    @Autowired
    private AlertService alertService;

    @ModelAttribute("unacknowledgedAlerts")
    public int unacknowledgedAlerts() {
        try {
            return Math.toIntExact(alertService.countUnacknowledgedAlerts());
        } catch (Exception e) {
            log.warn("Could not fetch unacknowledged alerts count: {}", e.getMessage());
            return 0;
        }
    }
}
