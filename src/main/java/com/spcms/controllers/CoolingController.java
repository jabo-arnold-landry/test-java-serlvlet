package com.spcms.controllers;

import com.spcms.models.CoolingUnit;
import com.spcms.models.MonitoringLog;
import com.spcms.services.CoolingService;
import com.spcms.services.MonitoringService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/cooling")
public class CoolingController {

    @Autowired
    private CoolingService coolingService;

    @Autowired
    private MonitoringService monitoringService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
        return "cooling/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("coolingUnit", new CoolingUnit());
        return "cooling/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute CoolingUnit coolingUnit, RedirectAttributes redirectAttributes) {
        coolingService.createCoolingUnit(coolingUnit);
        redirectAttributes.addFlashAttribute("success", "Cooling unit saved successfully");
        return "redirect:/cooling";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("coolingUnit", coolingService.getCoolingUnitById(id)
                .orElseThrow(() -> new RuntimeException("Cooling unit not found")));
        return "cooling/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("coolingUnit", coolingService.getCoolingUnitById(id)
                .orElseThrow(() -> new RuntimeException("Cooling unit not found")));
        model.addAttribute("alarms", coolingService.getAlarmsByCoolingUnit(id));
        return "cooling/view";
    }

    @GetMapping("/report")
    public String reportForm(@RequestParam(value = "coolingId", required = false) Long coolingId, Model model) {
        model.addAttribute("coolingUnits", coolingService.getAllCoolingUnits());

        if (coolingId != null) {
            CoolingUnit selected = coolingService.getCoolingUnitById(coolingId).orElse(null);
            model.addAttribute("selectedCooling", selected);
            List<MonitoringLog> logs = monitoringService.getReadingsForEquipment(
                    MonitoringLog.EquipmentType.COOLING, coolingId);

            MonitoringSummary summary;
            if (logs.isEmpty() && selected != null) {
                summary = buildSummaryFromUnit(selected);
                model.addAttribute("summarySource", "snapshot");
            } else {
                summary = buildSummary(logs, selected != null ? selected.getStatus() : null);
                model.addAttribute("summarySource", "logs");
            }

            Map<Long, String> reportPerformance = new HashMap<>();
            if (!logs.isEmpty()) {
                BigDecimal tempThreshold = new BigDecimal("28");
                BigDecimal highHumidityThreshold = new BigDecimal("65");
                BigDecimal lowHumidityThreshold = new BigDecimal("30");
                CoolingUnit.CoolingStatus status = selected != null ? selected.getStatus() : null;
                for (MonitoringLog log : logs) {
                    reportPerformance.put(log.getLogId(), classifyPerformance(
                            log.getCoolingPerformance(),
                            log.getReturnAirTemp(),
                            log.getHumidityPercent(),
                            tempThreshold,
                            highHumidityThreshold,
                            lowHumidityThreshold,
                            status
                    ));
                }
            }

            model.addAttribute("reportCoolingId", coolingId);
            model.addAttribute("reportLogs", logs);
            model.addAttribute("summary", summary);
            model.addAttribute("reportPerformance", reportPerformance);
        }

        return "cooling/report";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        coolingService.deleteCoolingUnit(id);
        redirectAttributes.addFlashAttribute("success", "Cooling unit deleted successfully");
        return "redirect:/cooling";
    }

    private MonitoringSummary buildSummary(List<MonitoringLog> logs, CoolingUnit.CoolingStatus status) {
        MonitoringSummary summary = new MonitoringSummary();
        summary.totalReadings = logs.size();

        BigDecimal sumReturn = BigDecimal.ZERO;
        BigDecimal sumSupply = BigDecimal.ZERO;
        BigDecimal sumHumidity = BigDecimal.ZERO;
        int countReturn = 0;
        int countSupply = 0;
        int countHumidity = 0;

        BigDecimal maxReturn = null;
        BigDecimal minReturn = null;
        BigDecimal maxHumidity = null;
        BigDecimal minHumidity = null;

        int highTempCount = 0;
        int highHumidityCount = 0;
        int lowHumidityCount = 0;
        int performanceGoodCount = 0;
        int performanceWarningCount = 0;
        int performanceDegradedCount = 0;
        int performanceOtherCount = 0;

        BigDecimal tempThreshold = new BigDecimal("28");
        BigDecimal highHumidityThreshold = new BigDecimal("65");
        BigDecimal lowHumidityThreshold = new BigDecimal("30");

        for (MonitoringLog log : logs) {
            BigDecimal returnTemp = log.getReturnAirTemp();
            if (returnTemp != null) {
                sumReturn = sumReturn.add(returnTemp);
                countReturn++;
                maxReturn = (maxReturn == null || returnTemp.compareTo(maxReturn) > 0) ? returnTemp : maxReturn;
                minReturn = (minReturn == null || returnTemp.compareTo(minReturn) < 0) ? returnTemp : minReturn;
                if (returnTemp.compareTo(tempThreshold) > 0) {
                    highTempCount++;
                }
            }

            BigDecimal supplyTemp = log.getSupplyAirTemp();
            if (supplyTemp != null) {
                sumSupply = sumSupply.add(supplyTemp);
                countSupply++;
            }

            BigDecimal humidity = log.getHumidityPercent();
            if (humidity != null) {
                sumHumidity = sumHumidity.add(humidity);
                countHumidity++;
                maxHumidity = (maxHumidity == null || humidity.compareTo(maxHumidity) > 0) ? humidity : maxHumidity;
                minHumidity = (minHumidity == null || humidity.compareTo(minHumidity) < 0) ? humidity : minHumidity;
                if (humidity.compareTo(highHumidityThreshold) > 0) {
                    highHumidityCount++;
                }
                if (humidity.compareTo(lowHumidityThreshold) < 0) {
                    lowHumidityCount++;
                }
            }

            String performance = classifyPerformance(
                    log.getCoolingPerformance(),
                    log.getReturnAirTemp(),
                    log.getHumidityPercent(),
                    tempThreshold,
                    highHumidityThreshold,
                    lowHumidityThreshold,
                    status
            );
            switch (performance) {
                case "GOOD":
                    performanceGoodCount++;
                    break;
                case "WARNING":
                    performanceWarningCount++;
                    break;
                case "DEGRADED":
                    performanceDegradedCount++;
                    break;
                default:
                    performanceOtherCount++;
                    break;
            }
        }

        summary.avgReturnTemp = average(sumReturn, countReturn);
        summary.avgSupplyTemp = average(sumSupply, countSupply);
        summary.avgHumidity = average(sumHumidity, countHumidity);
        summary.maxReturnTemp = maxReturn;
        summary.minReturnTemp = minReturn;
        summary.maxHumidity = maxHumidity;
        summary.minHumidity = minHumidity;
        summary.highTempCount = highTempCount;
        summary.highHumidityCount = highHumidityCount;
        summary.lowHumidityCount = lowHumidityCount;
        summary.performanceGoodCount = performanceGoodCount;
        summary.performanceWarningCount = performanceWarningCount;
        summary.performanceDegradedCount = performanceDegradedCount;
        summary.performanceOtherCount = performanceOtherCount;
        summary.performanceMostCommon = mostCommonPerformance(
                performanceGoodCount,
                performanceWarningCount,
                performanceDegradedCount,
                performanceOtherCount
        );

        return summary;
    }

    private MonitoringSummary buildSummaryFromUnit(CoolingUnit unit) {
        MonitoringSummary summary = new MonitoringSummary();
        summary.totalReadings = 0;

        BigDecimal returnTemp = unit.getReturnAirTemp();
        BigDecimal supplyTemp = unit.getSupplyAirTemp();
        BigDecimal humidity = unit.getHumidityPercent();

        summary.avgReturnTemp = returnTemp;
        summary.avgSupplyTemp = supplyTemp;
        summary.avgHumidity = humidity;
        summary.maxReturnTemp = returnTemp;
        summary.minReturnTemp = returnTemp;
        summary.maxHumidity = humidity;
        summary.minHumidity = humidity;

        if (returnTemp != null && returnTemp.compareTo(new BigDecimal("28")) > 0) {
            summary.highTempCount = 1;
        }
        if (humidity != null && humidity.compareTo(new BigDecimal("65")) > 0) {
            summary.highHumidityCount = 1;
        }
        if (humidity != null && humidity.compareTo(new BigDecimal("30")) < 0) {
            summary.lowHumidityCount = 1;
        }

        String performance = classifyPerformance(
                null,
                unit.getReturnAirTemp(),
                unit.getHumidityPercent(),
                new BigDecimal("28"),
                new BigDecimal("65"),
                new BigDecimal("30"),
                unit.getStatus()
        );
        switch (performance) {
            case "GOOD":
                summary.performanceGoodCount = 1;
                break;
            case "WARNING":
                summary.performanceWarningCount = 1;
                break;
            case "DEGRADED":
                summary.performanceDegradedCount = 1;
                break;
            default:
                summary.performanceOtherCount = 1;
                break;
        }
        summary.performanceMostCommon = performance.equals("OTHER") ? "N/A" : performance;

        return summary;
    }

    private BigDecimal average(BigDecimal sum, int count) {
        if (count == 0) {
            return null;
        }
        return sum.divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP);
    }

    private String classifyPerformance(String performance,
                                       BigDecimal returnTemp,
                                       BigDecimal humidity,
                                       BigDecimal tempThreshold,
                                       BigDecimal highHumidityThreshold,
                                       BigDecimal lowHumidityThreshold,
                                       CoolingUnit.CoolingStatus status) {
        if (status == null || status != CoolingUnit.CoolingStatus.ACTIVE) {
            return "DEGRADED";
        }

        if (performance != null) {
            String normalized = performance.trim().toLowerCase();
            if (normalized.contains("degrad") || normalized.contains("poor") || normalized.contains("critical")) {
                return "DEGRADED";
            }
            if (normalized.contains("warn")) {
                return "WARNING";
            }
            if (normalized.contains("good") || normalized.contains("normal") || normalized.contains("ok")) {
                return "GOOD";
            }
        }

        if (returnTemp != null && returnTemp.compareTo(tempThreshold) > 0) {
            return "DEGRADED";
        }
        if (humidity != null && (humidity.compareTo(highHumidityThreshold) > 0
                || humidity.compareTo(lowHumidityThreshold) < 0)) {
            return "WARNING";
        }
        if (returnTemp != null || humidity != null) {
            return "GOOD";
        }
        return "OTHER";
    }

    private String mostCommonPerformance(int good, int warning, int degraded, int other) {
        int max = Math.max(Math.max(good, warning), Math.max(degraded, other));
        if (max == 0) {
            return "N/A";
        }
        boolean goodTop = good == max;
        boolean warningTop = warning == max;
        boolean degradedTop = degraded == max;
        boolean otherTop = other == max;

        int topCount = (goodTop ? 1 : 0) + (warningTop ? 1 : 0) + (degradedTop ? 1 : 0) + (otherTop ? 1 : 0);
        if (topCount > 1) {
            return "Mixed";
        }
        if (goodTop) return "GOOD";
        if (warningTop) return "WARNING";
        if (degradedTop) return "DEGRADED";
        return "OTHER";
    }

    public static class MonitoringSummary {
        private int totalReadings;
        private BigDecimal avgReturnTemp;
        private BigDecimal avgSupplyTemp;
        private BigDecimal avgHumidity;
        private BigDecimal maxReturnTemp;
        private BigDecimal minReturnTemp;
        private BigDecimal maxHumidity;
        private BigDecimal minHumidity;
        private int highTempCount;
        private int highHumidityCount;
        private int lowHumidityCount;
        private int performanceGoodCount;
        private int performanceWarningCount;
        private int performanceDegradedCount;
        private int performanceOtherCount;
        private String performanceMostCommon;

        public int getTotalReadings() {
            return totalReadings;
        }

        public BigDecimal getAvgReturnTemp() {
            return avgReturnTemp;
        }

        public BigDecimal getAvgSupplyTemp() {
            return avgSupplyTemp;
        }

        public BigDecimal getAvgHumidity() {
            return avgHumidity;
        }

        public BigDecimal getMaxReturnTemp() {
            return maxReturnTemp;
        }

        public BigDecimal getMinReturnTemp() {
            return minReturnTemp;
        }

        public BigDecimal getMaxHumidity() {
            return maxHumidity;
        }

        public BigDecimal getMinHumidity() {
            return minHumidity;
        }

        public int getHighTempCount() {
            return highTempCount;
        }

        public int getHighHumidityCount() {
            return highHumidityCount;
        }

        public int getLowHumidityCount() {
            return lowHumidityCount;
        }

        public int getPerformanceGoodCount() {
            return performanceGoodCount;
        }

        public int getPerformanceWarningCount() {
            return performanceWarningCount;
        }

        public int getPerformanceDegradedCount() {
            return performanceDegradedCount;
        }

        public int getPerformanceOtherCount() {
            return performanceOtherCount;
        }

        public String getPerformanceMostCommon() {
            return performanceMostCommon;
        }
    }
}
