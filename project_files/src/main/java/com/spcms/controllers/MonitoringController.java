package com.spcms.controllers;

import com.spcms.models.MonitoringLog;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
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
    private UserRepository userRepository;

    @GetMapping
    public String list(Model model) {
        // Keep both keys for backward compatibility across monitoring views.
        var readings = monitoringService.getAllReadings();
        model.addAttribute("readings", readings);
        model.addAttribute("logs", readings);
        return "monitoring/list";
    }

    @GetMapping("/new")
    public String showRecordForm(Model model) {
        model.addAttribute("monitoringLog", new MonitoringLog());
        return "monitoring/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute MonitoringLog log,
            @RequestParam(value = "recordedByUserId", required = false) Long recordedByUserId,
            RedirectAttributes redirectAttributes) {
        if (recordedByUserId != null) {
            User user = userRepository.findById(recordedByUserId).orElse(null);
            log.setRecordedBy(user);
        }
        if (log.getLogId() != null) {
            monitoringService.updateReading(log);
            redirectAttributes.addFlashAttribute("success", "Reading updated successfully");
        } else {
            monitoringService.recordReading(log);
            redirectAttributes.addFlashAttribute("success", "Reading recorded successfully");
        }
        return "redirect:/monitoring";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable("id") Long id, Model model) {
        model.addAttribute("monitoringLog", monitoringService.getReadingById(id)
                .orElseThrow(() -> new RuntimeException("Reading not found")));
        model.addAttribute("viewMode", true);
        return "monitoring/form";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable("id") Long id, Model model) {
        model.addAttribute("monitoringLog", monitoringService.getReadingById(id)
                .orElseThrow(() -> new RuntimeException("Reading not found")));
        return "monitoring/form";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        System.out.println("DEBUG: Deleting monitoring reading with ID: " + id);
        try {
            monitoringService.deleteReading(id);
            redirectAttributes.addFlashAttribute("success", "Reading deleted successfully");
            System.out.println("DEBUG: Delete successful for ID: " + id);
        } catch (Exception e) {
            System.err.println("DEBUG: Error deleting reading ID " + id + ": " + e.getMessage());
            redirectAttributes.addFlashAttribute("error", "Error deleting reading: " + e.getMessage());
        }
        return "redirect:/monitoring";
    }

    @GetMapping("/report")
    public String report(Model model) {
        var allReadings = monitoringService.getAllReadings();

        // Total counts
        long totalReadings = allReadings.size();
        long upsReadings = allReadings.stream()
                .filter(r -> r.getEquipmentType() == MonitoringLog.EquipmentType.UPS).count();
        long coolingReadings = allReadings.stream()
                .filter(r -> r.getEquipmentType() == MonitoringLog.EquipmentType.COOLING).count();

        // UPS averages
        var upsLogs = allReadings.stream()
                .filter(r -> r.getEquipmentType() == MonitoringLog.EquipmentType.UPS)
                .toList();
        Double avgLoad = upsLogs.stream()
                .filter(r -> r.getLoadPercentage() != null)
                .mapToDouble(r -> r.getLoadPercentage().doubleValue()).average().orElse(0);
        Double avgTemp = upsLogs.stream()
                .filter(r -> r.getTemperature() != null)
                .mapToDouble(r -> r.getTemperature().doubleValue()).average().orElse(0);

        // Cooling averages
        var coolingLogs = allReadings.stream()
                .filter(r -> r.getEquipmentType() == MonitoringLog.EquipmentType.COOLING)
                .toList();
        Double avgReturnAir = coolingLogs.stream()
                .filter(r -> r.getReturnAirTemp() != null)
                .mapToDouble(r -> r.getReturnAirTemp().doubleValue()).average().orElse(0);
        Double avgSupplyAir = coolingLogs.stream()
                .filter(r -> r.getSupplyAirTemp() != null)
                .mapToDouble(r -> r.getSupplyAirTemp().doubleValue()).average().orElse(0);
        Double avgHumidity = coolingLogs.stream()
                .filter(r -> r.getHumidityPercent() != null)
                .mapToDouble(r -> r.getHumidityPercent().doubleValue()).average().orElse(0);

        model.addAttribute("totalReadings", totalReadings);
        model.addAttribute("upsReadings", upsReadings);
        model.addAttribute("coolingReadings", coolingReadings);
        model.addAttribute("avgLoad", String.format("%.1f", avgLoad));
        model.addAttribute("avgTemp", String.format("%.1f", avgTemp));
        model.addAttribute("avgReturnAir", String.format("%.1f", avgReturnAir));
        model.addAttribute("avgSupplyAir", String.format("%.1f", avgSupplyAir));
        model.addAttribute("avgHumidity", String.format("%.1f", avgHumidity));
        model.addAttribute("recentReadings", allReadings.stream().limit(10).toList());

        return "monitoring/report";
    }
}
