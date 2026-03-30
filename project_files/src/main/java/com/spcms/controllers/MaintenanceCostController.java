package com.spcms.controllers;

import com.spcms.models.MaintenanceCostEntry;
import com.spcms.models.MaintenanceCostEntry.EquipmentType;
import com.spcms.services.MaintenanceCostEntryService;
import com.spcms.services.MaintenanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Controller
@RequestMapping("/maintenance-costs")
public class MaintenanceCostController {

    @Autowired
    private MaintenanceCostEntryService costService;

    @Autowired
    private MaintenanceService maintenanceService;

    // ==================== Cost Analysis Dashboard ====================

    @GetMapping
    public String costAnalysisDashboard(
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "equipmentType", required = false) String equipmentTypeStr,
            Model model) {

        if (endDate == null) endDate = LocalDate.now();
        if (startDate == null) startDate = endDate.minusDays(90);

        LocalDateTime startDt = startDate.atStartOfDay();
        LocalDateTime endDt = endDate.atTime(LocalTime.MAX);

        EquipmentType eqType = null;
        if ("UPS".equals(equipmentTypeStr)) eqType = EquipmentType.UPS;
        else if ("COOLING".equals(equipmentTypeStr)) eqType = EquipmentType.COOLING;

        // Filtered cost entries
        List<MaintenanceCostEntry> costEntries = costService.findFiltered(eqType, startDt, endDt);

        // Aggregations for the filtered period
        BigDecimal totalCost = costService.getCostByDateRange(startDt, endDt);
        BigDecimal upsCost = costService.getCostByTypeAndDateRange(EquipmentType.UPS, startDt, endDt);
        BigDecimal coolingCost = costService.getCostByTypeAndDateRange(EquipmentType.COOLING, startDt, endDt);

        // Monthly trends (last 12 months)
        LocalDate now = LocalDate.now();
        String[] monthLabels = new String[12];
        BigDecimal[] monthlyUpsCosts = new BigDecimal[12];
        BigDecimal[] monthlyCoolingCosts = new BigDecimal[12];

        for (int i = 11; i >= 0; i--) {
            LocalDate monthStart = now.minusMonths(i).withDayOfMonth(1);
            LocalDate monthEnd = monthStart.plusMonths(1).minusDays(1);
            monthLabels[11 - i] = monthStart.getMonth().name().substring(0, 3) + " " + monthStart.getYear();
            monthlyUpsCosts[11 - i] = costService.getCostByTypeAndDateRange(EquipmentType.UPS,
                    monthStart.atStartOfDay(), monthEnd.atTime(LocalTime.MAX));
            monthlyCoolingCosts[11 - i] = costService.getCostByTypeAndDateRange(EquipmentType.COOLING,
                    monthStart.atStartOfDay(), monthEnd.atTime(LocalTime.MAX));
        }

        // Quarterly trends (last 4 quarters)
        String[] quarterLabels = new String[4];
        BigDecimal[] quarterlyUpsCosts = new BigDecimal[4];
        BigDecimal[] quarterlyCoolingCosts = new BigDecimal[4];

        for (int q = 3; q >= 0; q--) {
            LocalDate qStart = now.minusMonths((long) q * 3).withDayOfMonth(1);
            LocalDate qEnd = qStart.plusMonths(3).minusDays(1);
            quarterLabels[3 - q] = "Q" + ((qStart.getMonthValue() - 1) / 3 + 1) + " " + qStart.getYear();
            quarterlyUpsCosts[3 - q] = costService.getCostByTypeAndDateRange(EquipmentType.UPS,
                    qStart.atStartOfDay(), qEnd.atTime(LocalTime.MAX));
            quarterlyCoolingCosts[3 - q] = costService.getCostByTypeAndDateRange(EquipmentType.COOLING,
                    qStart.atStartOfDay(), qEnd.atTime(LocalTime.MAX));
        }

        model.addAttribute("costEntries", costEntries);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("equipmentType", equipmentTypeStr != null ? equipmentTypeStr : "ALL");
        model.addAttribute("totalCost", totalCost);
        model.addAttribute("upsCost", upsCost);
        model.addAttribute("coolingCost", coolingCost);

        model.addAttribute("monthLabels", monthLabels);
        model.addAttribute("monthlyUpsCosts", monthlyUpsCosts);
        model.addAttribute("monthlyCoolingCosts", monthlyCoolingCosts);
        model.addAttribute("quarterLabels", quarterLabels);
        model.addAttribute("quarterlyUpsCosts", quarterlyUpsCosts);
        model.addAttribute("quarterlyCoolingCosts", quarterlyCoolingCosts);

        return "cost-analysis/cost-dashboard";
    }

    // ==================== Add/Edit Cost Form ====================

    @GetMapping("/add")
    public String showAddForm(@RequestParam Long maintenanceId,
                               @RequestParam String equipmentType,
                               Model model) {
        MaintenanceCostEntry entry = new MaintenanceCostEntry();
        entry.setMaintenanceId(maintenanceId);
        entry.setEquipmentType(EquipmentType.valueOf(equipmentType));
        model.addAttribute("costEntry", entry);
        model.addAttribute("isEdit", false);
        return "cost-analysis/cost-entry-form";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return costService.findById(id)
                .map(entry -> {
                    model.addAttribute("costEntry", entry);
                    model.addAttribute("isEdit", true);
                    return "cost-analysis/cost-entry-form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Cost entry not found");
                    return "redirect:/maintenance-costs";
                });
    }

    @PostMapping("/save")
    public String saveCost(@ModelAttribute MaintenanceCostEntry entry,
                            RedirectAttributes redirectAttributes, HttpServletRequest request) {
        try {
            costService.save(entry, request);
            redirectAttributes.addFlashAttribute("success", "Cost entry saved successfully");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/maintenance-costs";
    }

    @PostMapping("/delete/{id}")
    public String deleteCost(@PathVariable Long id, RedirectAttributes redirectAttributes,
                              HttpServletRequest request) {
        costService.delete(id, request);
        redirectAttributes.addFlashAttribute("success", "Cost entry deleted successfully");
        return "redirect:/maintenance-costs";
    }

    // ==================== Costs for a specific maintenance record ====================

    @GetMapping("/for/{equipmentType}/{maintenanceId}")
    public String costsForRecord(@PathVariable String equipmentType, @PathVariable Long maintenanceId,
                                  Model model) {
        EquipmentType eqType = EquipmentType.valueOf(equipmentType.toUpperCase());
        List<MaintenanceCostEntry> costs = costService.findByMaintenanceRecord(maintenanceId, eqType);
        model.addAttribute("costs", costs);
        model.addAttribute("maintenanceId", maintenanceId);
        model.addAttribute("equipmentType", equipmentType.toUpperCase());
        return "cost-analysis/costs-for-record";
    }
}
