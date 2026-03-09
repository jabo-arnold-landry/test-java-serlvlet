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

    @GetMapping
    public String list(Model model) {
        model.addAttribute("readings", monitoringService.getAllReadings());
        return "monitoring/list";
    }

    @GetMapping("/new")
    public String showRecordForm(Model model) {
        model.addAttribute("monitoringLog", new MonitoringLog());
        return "monitoring/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute MonitoringLog log, RedirectAttributes redirectAttributes) {
        monitoringService.recordReading(log);
        redirectAttributes.addFlashAttribute("success", "Reading recorded successfully");
        return "redirect:/monitoring";
    }
}
