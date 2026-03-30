package com.spcms.controllers;

import com.spcms.models.User;
import com.spcms.services.AlertService;
import com.spcms.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/alerts")
public class AlertController {

    @Autowired
    private AlertService alertService;

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("alerts", alertService.getAllAlerts());
        model.addAttribute("unacknowledgedAlerts", alertService.getUnacknowledgedAlerts().size());
        return "alerts/list";
    }

    @PostMapping("/acknowledge/{id}")
    public String acknowledge(@PathVariable Long id,
                               Authentication authentication,
                               RedirectAttributes redirectAttributes) {
        User currentUser = userService.getUserByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        alertService.acknowledgeAlert(id, currentUser.getUserId());
        redirectAttributes.addFlashAttribute("success", "Alert acknowledged");
        return "redirect:/alerts";
    }
}
