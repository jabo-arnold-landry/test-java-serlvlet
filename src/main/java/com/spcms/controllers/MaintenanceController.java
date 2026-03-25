package com.spcms.controllers;

import com.spcms.services.MaintenanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spcms.models.UpsMaintenance;
import com.spcms.models.CoolingMaintenance;

@Controller
@RequestMapping("/maintenance")
public class MaintenanceController {

    @Autowired
    private MaintenanceService maintenanceService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("overdueUps", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());
        model.addAttribute("allUpsMaintenance", maintenanceService.getAllUpsMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());
        return "maintenance/list";
    }

    @GetMapping("/ups/new")
    public String showUpsMaintenanceForm(Model model) {
        model.addAttribute("upsMaintenance", new UpsMaintenance());
        return "maintenance/ups-form";
    }

    @PostMapping("/ups/save")
    public String saveUpsMaintenance(@ModelAttribute UpsMaintenance maintenance,
            RedirectAttributes redirectAttributes) {
        maintenanceService.scheduleUpsMaintenance(maintenance);
        redirectAttributes.addFlashAttribute("success", "UPS maintenance scheduled");
        return "redirect:/maintenance";
    }

    @GetMapping("/cooling/new")
    public String showCoolingMaintenanceForm(Model model) {
        model.addAttribute("coolingMaintenance", new CoolingMaintenance());
        return "maintenance/cooling-form";
    }

    @PostMapping("/cooling/save")
    public String saveCoolingMaintenance(@ModelAttribute CoolingMaintenance maintenance,
            RedirectAttributes redirectAttributes) {
        maintenanceService.scheduleCoolingMaintenance(maintenance);
        redirectAttributes.addFlashAttribute("success", "Cooling maintenance scheduled");
        return "redirect:/maintenance";
    }

    @PostMapping("/ups/schedule-quarterly")
    public String scheduleQuarterlyUps(@RequestParam Long upsId,
            @RequestParam String technician,
            @RequestParam String vendor,
            RedirectAttributes redirectAttributes) {
        maintenanceService.scheduleQuarterlyUpsMaintenance(upsId, technician, vendor);
        redirectAttributes.addFlashAttribute("success", "Quarterly UPS maintenance scheduled");
        return "redirect:/maintenance";
    }
}
