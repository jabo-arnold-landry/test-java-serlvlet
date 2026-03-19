package com.spcms.controllers;

import com.spcms.services.MaintenanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.spcms.models.UpsMaintenance;
import com.spcms.models.CoolingMaintenance;
import java.time.LocalDate;

import java.math.BigDecimal;

@Controller
@RequestMapping("/maintenance")
public class MaintenanceController {

    @Autowired
    private MaintenanceService maintenanceService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("overdueUps", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("overdueCooling", maintenanceService.getOverdueCoolingMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());
        model.addAttribute("allUpsMaintenance", maintenanceService.getAllUpsMaintenance());
        return "maintenance/list";
    }

    @GetMapping("/cost-analysis")
    public String costAnalysis(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            Model model) {

        LocalDate start = startDate != null && !startDate.isEmpty()
                ? LocalDate.parse(startDate) : LocalDate.now().minusMonths(12);
        LocalDate end = endDate != null && !endDate.isEmpty()
                ? LocalDate.parse(endDate) : LocalDate.now();

        var upsList = maintenanceService.getUpsMaintenanceByDateRange(start, end);
        var coolingList = maintenanceService.getCoolingMaintenanceByDateRange(start, end);

        java.math.BigDecimal totalUps = upsList.stream()
                .filter(m -> m.getMaintenanceCost() != null)
                .map(UpsMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        java.math.BigDecimal totalCooling = coolingList.stream()
                .filter(m -> m.getMaintenanceCost() != null)
                .map(CoolingMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        // Cost by type - UPS
        java.math.BigDecimal upsPreventive = upsList.stream()
                .filter(m -> m.getMaintenanceCost() != null && m.getMaintenanceType() == UpsMaintenance.MaintenanceType.PREVENTIVE)
                .map(UpsMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        java.math.BigDecimal upsCorrective = upsList.stream()
                .filter(m -> m.getMaintenanceCost() != null && m.getMaintenanceType() == UpsMaintenance.MaintenanceType.CORRECTIVE)
                .map(UpsMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        // Cost by type - Cooling
        java.math.BigDecimal coolingPreventive = coolingList.stream()
                .filter(m -> m.getMaintenanceCost() != null && m.getMaintenanceType() == CoolingMaintenance.MaintenanceType.PREVENTIVE)
                .map(CoolingMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        java.math.BigDecimal coolingCorrective = coolingList.stream()
                .filter(m -> m.getMaintenanceCost() != null && m.getMaintenanceType() == CoolingMaintenance.MaintenanceType.CORRECTIVE)
                .map(CoolingMaintenance::getMaintenanceCost)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        // Average costs
        java.math.BigDecimal avgUpsCost = upsList.isEmpty() ? java.math.BigDecimal.ZERO :
                totalUps.divide(java.math.BigDecimal.valueOf(upsList.size()), 2, java.math.RoundingMode.HALF_UP);

        java.math.BigDecimal avgCoolingCost = coolingList.isEmpty() ? java.math.BigDecimal.ZERO :
                totalCooling.divide(java.math.BigDecimal.valueOf(coolingList.size()), 2, java.math.RoundingMode.HALF_UP);

        model.addAttribute("upsMaintenance", upsList);
        model.addAttribute("coolingMaintenance", coolingList);
        model.addAttribute("totalUpsCost", totalUps);
        model.addAttribute("totalCoolingCost", totalCooling);
        model.addAttribute("grandTotal", totalUps.add(totalCooling));
        model.addAttribute("upsPreventiveCost", upsPreventive);
        model.addAttribute("upsCorrectiveCost", upsCorrective);
        model.addAttribute("coolingPreventiveCost", coolingPreventive);
        model.addAttribute("coolingCorrectiveCost", coolingCorrective);
        model.addAttribute("avgUpsCost", avgUpsCost);
        model.addAttribute("avgCoolingCost", avgCoolingCost);
        model.addAttribute("startDate", start);
        model.addAttribute("endDate", end);
        return "maintenance/cost-analysis";
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