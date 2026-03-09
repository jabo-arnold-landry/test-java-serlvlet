package com.spcms.config;

import com.spcms.services.AlertService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalModelAttributes {

    @Autowired
    private AlertService alertService;

    @ModelAttribute("unacknowledgedAlerts")
    public int unacknowledgedAlerts() {
        return alertService.getUnacknowledgedAlerts().size();
    }
}
