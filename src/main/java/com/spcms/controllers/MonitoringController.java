package com.spcms.controllers;

import com.spcms.models.MonitoringLog;
import com.spcms.models.User;
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

    @Autowired
    private com.spcms.repositories.UserRepository userRepository;

    @PostMapping("/save")
    public String save(@ModelAttribute MonitoringLog log, org.springframework.validation.BindingResult result, RedirectAttributes redirectAttributes, Model model) {
        if (result.hasErrors()) {
            StringBuilder errors = new StringBuilder("Binding errors: ");
            result.getAllErrors().forEach(e -> errors.append(e.getDefaultMessage()).append("; "));
            model.addAttribute("errorMsg", errors.toString());
            model.addAttribute("monitoringLog", log);
            return "monitoring/form";
        }
        
        try {
            if (log.getRecordedBy() != null && log.getRecordedBy().getUserId() != null) {
                User user = userRepository.findById(log.getRecordedBy().getUserId()).orElse(null);
                if (user == null) {
                    throw new RuntimeException("User ID " + log.getRecordedBy().getUserId() + " does not exist.");
                }
                log.setRecordedBy(user);
            } else {
                log.setRecordedBy(null);
            }
            monitoringService.recordReading(log);
            redirectAttributes.addFlashAttribute("success", "Reading recorded successfully");
            return "redirect:/monitoring";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMsg", "Error saving reading: " + e.getMessage());
            model.addAttribute("monitoringLog", log);
            return "monitoring/form"; // Stay on the form and display error
        }
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable Long id, Model model) {
        MonitoringLog log = monitoringService.getReadingById(id).orElse(null);
        if (log == null) return "redirect:/monitoring";
        model.addAttribute("monitoringLog", log);
        return "monitoring/form";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        monitoringService.deleteReading(id);
        redirectAttributes.addFlashAttribute("success", "Reading deleted successfully");
        return "redirect:/monitoring";
    }
}
