package com.spcms.controllers;

import com.spcms.models.CoolingMaintenance;
import com.spcms.models.UpsMaintenance;
import com.spcms.services.MaintenanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/isolated-cost-analysis")
public class IsolatedCostAnalysisController {

    @Autowired
    private MaintenanceService maintenanceService;

    @GetMapping
    public String viewIsolatedCostAnalysis(
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Model model) {

        if (endDate == null) {
            endDate = LocalDate.now();
        }
        if (startDate == null) {
            startDate = endDate.minusDays(30); // Default to last 30 days
        }

        List<UpsMaintenance> upsMaintenance = maintenanceService.getUpsMaintenanceByDateRange(startDate, endDate);
        List<CoolingMaintenance> coolingMaintenance = maintenanceService.getCoolingMaintenanceByDateRange(startDate, endDate);

        BigDecimal totalUpsCost = BigDecimal.ZERO;
        BigDecimal upsPreventiveCost = BigDecimal.ZERO;
        BigDecimal upsCorrectiveCost = BigDecimal.ZERO;

        for (UpsMaintenance m : upsMaintenance) {
            BigDecimal cost = m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO;
            totalUpsCost = totalUpsCost.add(cost);
            if (m.getMaintenanceType() == UpsMaintenance.MaintenanceType.PREVENTIVE) {
                upsPreventiveCost = upsPreventiveCost.add(cost);
            } else if (m.getMaintenanceType() == UpsMaintenance.MaintenanceType.CORRECTIVE) {
                upsCorrectiveCost = upsCorrectiveCost.add(cost);
            }
        }

        BigDecimal totalCoolingCost = BigDecimal.ZERO;
        BigDecimal coolingPreventiveCost = BigDecimal.ZERO;
        BigDecimal coolingCorrectiveCost = BigDecimal.ZERO;

        for (CoolingMaintenance m : coolingMaintenance) {
            BigDecimal cost = m.getMaintenanceCost() != null ? m.getMaintenanceCost() : BigDecimal.ZERO;
            totalCoolingCost = totalCoolingCost.add(cost);
            if (m.getMaintenanceType() == CoolingMaintenance.MaintenanceType.PREVENTIVE) {
                coolingPreventiveCost = coolingPreventiveCost.add(cost);
            } else if (m.getMaintenanceType() == CoolingMaintenance.MaintenanceType.CORRECTIVE) {
                coolingCorrectiveCost = coolingCorrectiveCost.add(cost);
            }
        }

        BigDecimal grandTotal = totalUpsCost.add(totalCoolingCost);

        BigDecimal avgUpsCost = upsMaintenance.isEmpty() ? BigDecimal.ZERO : 
                totalUpsCost.divide(new BigDecimal(upsMaintenance.size()), 2, RoundingMode.HALF_UP);
        BigDecimal avgCoolingCost = coolingMaintenance.isEmpty() ? BigDecimal.ZERO : 
                totalCoolingCost.divide(new BigDecimal(coolingMaintenance.size()), 2, RoundingMode.HALF_UP);

        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("upsMaintenance", upsMaintenance);
        model.addAttribute("coolingMaintenance", coolingMaintenance);
        
        model.addAttribute("totalUpsCost", totalUpsCost);
        model.addAttribute("upsPreventiveCost", upsPreventiveCost);
        model.addAttribute("upsCorrectiveCost", upsCorrectiveCost);
        model.addAttribute("avgUpsCost", avgUpsCost);

        model.addAttribute("totalCoolingCost", totalCoolingCost);
        model.addAttribute("coolingPreventiveCost", coolingPreventiveCost);
        model.addAttribute("coolingCorrectiveCost", coolingCorrectiveCost);
        model.addAttribute("avgCoolingCost", avgCoolingCost);

        model.addAttribute("grandTotal", grandTotal);

        return "cost-analysis/isolated-analysis";
    }
}
