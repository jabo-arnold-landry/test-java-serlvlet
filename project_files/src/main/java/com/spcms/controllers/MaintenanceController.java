package com.spcms.controllers;

import com.spcms.models.CoolingMaintenance;
import com.spcms.models.UpsMaintenance;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.ActivityLogService;
import com.spcms.services.FileStorageService;
import com.spcms.services.MaintenanceReminderService;
import com.spcms.services.MaintenanceService;
import com.spcms.services.UpsService;
import com.spcms.services.CoolingService;
import com.spcms.services.MaintenanceHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/maintenance")
public class MaintenanceController {

    @Autowired
    private MaintenanceService maintenanceService;

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private MaintenanceReminderService reminderService;

    @Autowired
    private UpsService upsService;

    @Autowired
    private CoolingService coolingService;

    @Autowired
    private ActivityLogService activityLogService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MaintenanceHistoryService historyService;

    // ==================== List ====================

    @GetMapping
    public String list(Model model) {
        model.addAttribute("overdueUps", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("overdueCooling", maintenanceService.getOverdueCoolingMaintenance());
        model.addAttribute("upcomingUps", maintenanceService.getUpcomingUpsMaintenance());
        model.addAttribute("upcomingCooling", maintenanceService.getUpcomingCoolingMaintenance());
        model.addAttribute("allUpsMaintenance", maintenanceService.getAllUpsMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());
        return "maintenance/list";
    }

    // ==================== UPS Maintenance ====================

    @GetMapping("/ups/new")
    public String showUpsMaintenanceForm(Model model) {
        model.addAttribute("upsMaintenance", new UpsMaintenance());
        model.addAttribute("isEdit", false);
        model.addAttribute("upsList", upsService.getAllUps());
        model.addAttribute("technicianList", userRepository.findByRole(User.Role.TECHNICIAN));
        return "maintenance/ups-form";
    }

    @GetMapping("/ups/edit/{id}")
    public String editUpsMaintenanceForm(@PathVariable Long id, Model model,
                                         RedirectAttributes redirectAttributes) {
        return maintenanceService.getUpsMaintenanceById(id)
                .map(m -> {
                    model.addAttribute("upsMaintenance", m);
                    model.addAttribute("isEdit", true);
                    model.addAttribute("upsList", upsService.getAllUps());
                    model.addAttribute("technicianList", userRepository.findByRole(User.Role.TECHNICIAN));
                    return "maintenance/ups-form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "UPS maintenance record not found");
                    return "redirect:/maintenance";
                });
    }

    @PostMapping("/ups/save")
    public String saveUpsMaintenance(@ModelAttribute UpsMaintenance maintenance,
                                     @RequestParam(value = "serviceReportFile", required = false) MultipartFile serviceReportFile,
            RedirectAttributes redirectAttributes, HttpServletRequest request) {
        boolean isEdit = maintenance.getMaintenanceId() != null;

        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            try {
                String filePath = fileStorageService.storeServiceReport(serviceReportFile);
                maintenance.setServiceReportPath(filePath);
            } catch (RuntimeException ex) {
                redirectAttributes.addFlashAttribute("error", "Failed to upload UPS service report: " + ex.getMessage());
                return "redirect:/maintenance";
            }
        } else if (maintenance.getMaintenanceId() != null) {
            maintenanceService.getUpsMaintenanceById(maintenance.getMaintenanceId())
                    .ifPresent(existing -> {
                        if (maintenance.getServiceReportPath() == null || maintenance.getServiceReportPath().isBlank()) {
                            maintenance.setServiceReportPath(existing.getServiceReportPath());
                        }
                    });
        }

        UpsMaintenance saved = maintenanceService.scheduleUpsMaintenance(maintenance);
        String action = isEdit ? "UPDATED" : "CREATED";
        activityLogService.log(action, "UPS_MAINTENANCE", saved.getMaintenanceId(),
                "UPS maintenance record " + action.toLowerCase() + ". Technician: " + saved.getTechnician()
                        + ", Type: " + saved.getMaintenanceType(), request);

        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            activityLogService.log("FILE_UPLOAD", "UPS_MAINTENANCE", saved.getMaintenanceId(),
                    "Service report uploaded: " + serviceReportFile.getOriginalFilename(), request);
        }

        redirectAttributes.addFlashAttribute("success", "UPS maintenance record " + action.toLowerCase() + " successfully");
        return "redirect:/maintenance";
    }

    @PostMapping("/ups/delete/{id}")
    public String deleteUpsMaintenance(@PathVariable Long id, RedirectAttributes redirectAttributes,
                                       HttpServletRequest request) {
        maintenanceService.getUpsMaintenanceById(id).ifPresent(m -> {
            if (m.getServiceReportPath() != null && !m.getServiceReportPath().isBlank()) {
                fileStorageService.deleteFile(m.getServiceReportPath());
            }
        });
        maintenanceService.deleteUpsMaintenance(id);
        activityLogService.log("DELETED", "UPS_MAINTENANCE", id,
                "UPS maintenance record deleted", request);
        redirectAttributes.addFlashAttribute("success", "UPS maintenance record deleted successfully");
        return "redirect:/maintenance";
    }

    // ==================== Cooling Maintenance ====================

    @GetMapping("/cooling/new")
    public String showCoolingMaintenanceForm(Model model) {
        model.addAttribute("coolingMaintenance", new CoolingMaintenance());
        model.addAttribute("isEdit", false);
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
        model.addAttribute("technicianList", userRepository.findByRole(User.Role.TECHNICIAN));
        return "maintenance/cooling-form";
    }

    @GetMapping("/cooling/edit/{id}")
    public String editCoolingMaintenanceForm(@PathVariable Long id, Model model,
                                             RedirectAttributes redirectAttributes) {
        return maintenanceService.getCoolingMaintenanceById(id)
                .map(m -> {
                    model.addAttribute("coolingMaintenance", m);
                    model.addAttribute("isEdit", true);
                    model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
                    model.addAttribute("technicianList", userRepository.findByRole(User.Role.TECHNICIAN));
                    return "maintenance/cooling-form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("error", "Cooling maintenance record not found");
                    return "redirect:/maintenance";
                });
    }

    @PostMapping("/cooling/save")
    public String saveCoolingMaintenance(@ModelAttribute CoolingMaintenance maintenance,
                                         @RequestParam(value = "serviceReportFile", required = false) MultipartFile serviceReportFile,
            RedirectAttributes redirectAttributes, HttpServletRequest request) {
        boolean isEdit = maintenance.getMaintenanceId() != null;

        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            try {
                String filePath = fileStorageService.storeServiceReport(serviceReportFile);
                maintenance.setServiceReportPath(filePath);
            } catch (RuntimeException ex) {
                redirectAttributes.addFlashAttribute("error", "Failed to upload Cooling service report: " + ex.getMessage());
                return "redirect:/maintenance";
            }
        } else if (maintenance.getMaintenanceId() != null) {
            maintenanceService.getCoolingMaintenanceById(maintenance.getMaintenanceId())
                    .ifPresent(existing -> {
                        if (maintenance.getServiceReportPath() == null || maintenance.getServiceReportPath().isBlank()) {
                            maintenance.setServiceReportPath(existing.getServiceReportPath());
                        }
                    });
        }

        CoolingMaintenance saved = maintenanceService.scheduleCoolingMaintenance(maintenance);
        String action = isEdit ? "UPDATED" : "CREATED";
        activityLogService.log(action, "COOLING_MAINTENANCE", saved.getMaintenanceId(),
                "Cooling maintenance record " + action.toLowerCase() + ". Technician: " + saved.getTechnician()
                        + ", Type: " + saved.getMaintenanceType(), request);

        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            activityLogService.log("FILE_UPLOAD", "COOLING_MAINTENANCE", saved.getMaintenanceId(),
                    "Service report uploaded: " + serviceReportFile.getOriginalFilename(), request);
        }

        redirectAttributes.addFlashAttribute("success", "Cooling maintenance record " + action.toLowerCase() + " successfully");
        return "redirect:/maintenance";
    }

    @PostMapping("/cooling/delete/{id}")
    public String deleteCoolingMaintenance(@PathVariable Long id, RedirectAttributes redirectAttributes,
                                            HttpServletRequest request) {
        maintenanceService.getCoolingMaintenanceById(id).ifPresent(m -> {
            if (m.getServiceReportPath() != null && !m.getServiceReportPath().isBlank()) {
                fileStorageService.deleteFile(m.getServiceReportPath());
            }
        });
        maintenanceService.deleteCoolingMaintenance(id);
        activityLogService.log("DELETED", "COOLING_MAINTENANCE", id,
                "Cooling maintenance record deleted", request);
        redirectAttributes.addFlashAttribute("success", "Cooling maintenance record deleted successfully");
        return "redirect:/maintenance";
    }

    // ==================== Quarterly Scheduling ====================

    // ==================== Download Report ====================

    @GetMapping("/download-report/{type}/{id}")
    public ResponseEntity<Resource> downloadServiceReport(@PathVariable String type, @PathVariable Long id) {
        String reportPath = null;

        if ("ups".equals(type)) {
            reportPath = maintenanceService.getUpsMaintenanceById(id)
                    .map(UpsMaintenance::getServiceReportPath).orElse(null);
        } else if ("cooling".equals(type)) {
            reportPath = maintenanceService.getCoolingMaintenanceById(id)
                    .map(CoolingMaintenance::getServiceReportPath).orElse(null);
        }

        if (reportPath == null || reportPath.isBlank()) {
            return ResponseEntity.notFound().build();
        }

        try {
            Path filePath = fileStorageService.getFilePath(reportPath);
            Resource resource = new UrlResource(filePath.toUri());
            if (!resource.exists()) {
                return ResponseEntity.notFound().build();
            }

            String filename = filePath.getFileName().toString();
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                    .body(resource);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // ==================== Maintenance Report (Statistics) ====================

    @GetMapping("/report")
    public String maintenanceReport(Model model) {
        model.addAttribute("totalUps", maintenanceService.getTotalUpsMaintenanceCount());
        model.addAttribute("totalCooling", maintenanceService.getTotalCoolingMaintenanceCount());
        model.addAttribute("upsPreventive", maintenanceService.getUpsPreventiveCount());
        model.addAttribute("upsCorrective", maintenanceService.getUpsCorrectiveCount());
        model.addAttribute("coolingPreventive", maintenanceService.getCoolingPreventiveCount());
        model.addAttribute("coolingCorrective", maintenanceService.getCoolingCorrectiveCount());

        model.addAttribute("overdueUps", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("overdueCooling", maintenanceService.getOverdueCoolingMaintenance());
        model.addAttribute("upcomingUps", maintenanceService.getUpcomingUpsMaintenance());
        model.addAttribute("upcomingCooling", maintenanceService.getUpcomingCoolingMaintenance());

        model.addAttribute("allUpsMaintenance", maintenanceService.getAllUpsMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());

        return "maintenance/report";
    }

    // ==================== Filterable Maintenance Reports ====================

    @GetMapping("/reports")
    public String maintenanceReports(
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "equipmentType", required = false, defaultValue = "ALL") String equipmentType,
            @RequestParam(value = "technician", required = false) String technician,
            Model model) {

        if (endDate == null) endDate = LocalDate.now();
        if (startDate == null) startDate = endDate.minusDays(90);

        List<UpsMaintenance> upsList = new ArrayList<>();
        List<CoolingMaintenance> coolingList = new ArrayList<>();

        if ("ALL".equals(equipmentType) || "UPS".equals(equipmentType)) {
            upsList = maintenanceService.getUpsMaintenanceByDateRange(startDate, endDate);
            if (technician != null && !technician.isBlank()) {
                upsList = upsList.stream()
                        .filter(m -> technician.equals(m.getTechnician()))
                        .collect(java.util.stream.Collectors.toList());
            }
        }

        if ("ALL".equals(equipmentType) || "COOLING".equals(equipmentType)) {
            coolingList = maintenanceService.getCoolingMaintenanceByDateRange(startDate, endDate);
            if (technician != null && !technician.isBlank()) {
                coolingList = coolingList.stream()
                        .filter(m -> technician.equals(m.getTechnician()))
                        .collect(java.util.stream.Collectors.toList());
            }
        }

        model.addAttribute("upsRecords", upsList);
        model.addAttribute("coolingRecords", coolingList);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("equipmentType", equipmentType);
        model.addAttribute("selectedTechnician", technician);
        model.addAttribute("technicianList", userRepository.findByRole(User.Role.TECHNICIAN));

        return "maintenance/maintenance-reports";
    }

    // ==================== Reminders ====================

    @PostMapping("/generate-reminders")
    public String generateReminders(RedirectAttributes redirectAttributes) {
        int count = reminderService.generateRemindersNow();
        redirectAttributes.addFlashAttribute("success",
                count + " maintenance reminder(s) generated and sent to the Alerts module");
        return "redirect:/maintenance";
    }

    // ==================== Maintenance History ====================

    @GetMapping("/history")
    public String maintenanceHistory(
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "equipmentType", required = false) String equipmentType,
            @RequestParam(value = "action", required = false) String action,
            @RequestParam(value = "userId", required = false) Long userId,
            Model model) {

        if (endDate == null) endDate = LocalDate.now();
        if (startDate == null) startDate = endDate.minusDays(90);

        var logs = historyService.getFilteredHistory(
                equipmentType, action, userId,
                startDate.atStartOfDay(), endDate.atTime(LocalTime.MAX));

        model.addAttribute("logs", logs);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("selectedEquipmentType", equipmentType);
        model.addAttribute("selectedAction", action);
        model.addAttribute("selectedUserId", userId);
        model.addAttribute("actionTypes", historyService.getDistinctActions());
        model.addAttribute("userList", historyService.getAllActiveUsers());

        return "maintenance/maintenance-history";
    }

    // ==================== Quarterly Cooling Scheduling ====================

    @PostMapping("/cooling/schedule-quarterly")
    public String scheduleQuarterlyCooling(
            @RequestParam("coolingUnitId") Long coolingUnitId,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "nextMaintenanceDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate nextMaintenanceDate,
            RedirectAttributes redirectAttributes,
            HttpServletRequest request) {

        try {
            LocalDate suggestedDate = (nextMaintenanceDate != null) ? nextMaintenanceDate : startDate.plusMonths(3);

            List<CoolingMaintenance> coolingMaintList = maintenanceService.getCoolingMaintenanceHistory(coolingUnitId);
            if (coolingMaintList != null && !coolingMaintList.isEmpty()) {
                CoolingMaintenance latest = coolingMaintList.get(0);
                latest.setNextMaintenanceDate(suggestedDate);
                maintenanceService.scheduleCoolingMaintenance(latest);

                activityLogService.log("QUARTERLY_SCHEDULE", "COOLING_MAINTENANCE",
                        latest.getMaintenanceId(),
                        "Quarterly scheduling: next due " + suggestedDate + " for cooling unit ID " + coolingUnitId,
                        request);

                redirectAttributes.addFlashAttribute("success",
                        "Quarterly maintenance scheduled for " + suggestedDate);
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "No existing maintenance record found for this cooling unit. Please create one first.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to schedule quarterly maintenance: " + e.getMessage());
        }

        return "redirect:/maintenance/cooling/new";
    }

    // ==================== Quarterly UPS Scheduling ====================

    @PostMapping("/ups/schedule-quarterly")
    public String scheduleQuarterlyUps(
            @RequestParam("upsId") Long upsId,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "nextDueDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate nextDueDate,
            RedirectAttributes redirectAttributes,
            HttpServletRequest request) {

        try {
            LocalDate suggestedDate = (nextDueDate != null) ? nextDueDate : startDate.plusMonths(3);

            List<UpsMaintenance> upsMaintList = maintenanceService.getUpsMaintenanceHistory(upsId);
            if (upsMaintList != null && !upsMaintList.isEmpty()) {
                UpsMaintenance latest = upsMaintList.get(0);
                latest.setNextDueDate(suggestedDate);
                maintenanceService.scheduleUpsMaintenance(latest);

                activityLogService.log("QUARTERLY_SCHEDULE", "UPS_MAINTENANCE",
                        latest.getMaintenanceId(),
                        "Quarterly scheduling: next due " + suggestedDate + " for UPS ID " + upsId,
                        request);

                redirectAttributes.addFlashAttribute("success",
                        "Quarterly UPS maintenance scheduled for " + suggestedDate);
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "No existing maintenance record found for this UPS. Please create one first.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to schedule quarterly maintenance: " + e.getMessage());
        }

        return "redirect:/maintenance/ups/new";
    }
}
