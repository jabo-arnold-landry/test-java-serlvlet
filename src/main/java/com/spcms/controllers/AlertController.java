package com.spcms.controllers;

import com.spcms.services.AlertService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/alerts")
public class AlertController {

    @Autowired
    private AlertService alertService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("alerts", alertService.getAllAlerts());
        model.addAttribute("unacknowledged", alertService.getUnacknowledgedAlerts());
        return "alerts/list";
    }

    @PostMapping("/acknowledge/{id}")
    public String acknowledge(@PathVariable Long id,
                               @RequestParam Long userId,
                               RedirectAttributes redirectAttributes) {
        alertService.acknowledgeAlert(id, userId);
        redirectAttributes.addFlashAttribute("success", "Alert acknowledged");
        return "redirect:/alerts";
    }
}
