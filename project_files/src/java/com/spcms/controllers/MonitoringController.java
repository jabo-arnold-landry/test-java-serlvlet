package com.spcms.controllers;

import com.spcms.models.MonitoringLog;
import com.spcms.services.MonitoringService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/monitoring")
public class MonitoringController {

    @Autowired
    private MonitoringService monitoringService;

    @Autowired
    private com.spcms.services.UpsService upsService;

    @Autowired
    private com.spcms.services.CoolingService coolingService;

    @Autowired
    private com.spcms.services.UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("readings", monitoringService.getAllReadings());
        return "monitoring/list";
    }

    @GetMapping("/new")
    public String showRecordForm(Model model) {
        model.addAttribute("monitoringLog", new MonitoringLog());
        model.addAttribute("upsList", upsService.getAllUps());
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
        return "monitoring/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute MonitoringLog log,
                       org.springframework.security.core.Authentication authentication,
                       RedirectAttributes redirectAttributes) {
        normalizeRecordedBy(log, authentication);
        monitoringService.recordReading(log);
        redirectAttributes.addFlashAttribute("success", "Reading recorded successfully");
        return "redirect:/monitoring";
    }

    private void normalizeRecordedBy(MonitoringLog log,
                                     org.springframework.security.core.Authentication authentication) {
        if (log.getRecordedBy() != null && log.getRecordedBy().getUserId() != null) {
            Long userId = log.getRecordedBy().getUserId();
            if (userService.getUserById(userId).isEmpty()) {
                log.setRecordedBy(null);
            }
        }

        if (log.getRecordedBy() == null || log.getRecordedBy().getUserId() == null) {
            if (authentication != null) {
                com.spcms.models.User currentUser = userService.getUserByUsername(authentication.getName())
                        .orElse(null);
                log.setRecordedBy(currentUser);
            }
        }
    }
}
