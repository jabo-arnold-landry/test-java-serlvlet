package com.spcms.controllers;

import com.spcms.models.CoolingMaintenance;
import com.spcms.models.UpsMaintenance;
import com.spcms.services.FileStorageService;
import com.spcms.services.MaintenanceReminderService;
import com.spcms.services.MaintenanceService;
import com.spcms.services.UpsService;
import com.spcms.services.CoolingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.file.Path;
import java.time.LocalDate;

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

    // ==================== List All Maintenance ====================

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

    // ==================== UPS Maintenance CRUD ====================

    @GetMapping("/ups/new")
    public String showUpsMaintenanceForm(Model model) {
        model.addAttribute("upsMaintenance", new UpsMaintenance());
        model.addAttribute("isEdit", false);
        model.addAttribute("upsList", upsService.getAllUps());
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
                                      RedirectAttributes redirectAttributes) {
        // Handle file upload
        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            String filePath = fileStorageService.storeServiceReport(serviceReportFile);
            maintenance.setServiceReportPath(filePath);
        } else if (maintenance.getMaintenanceId() != null) {
            // Preserve existing file path on edit if no new file uploaded
            maintenanceService.getUpsMaintenanceById(maintenance.getMaintenanceId())
                    .ifPresent(existing -> {
                        if (maintenance.getServiceReportPath() == null || maintenance.getServiceReportPath().isBlank()) {
                            maintenance.setServiceReportPath(existing.getServiceReportPath());
                        }
                    });
        }

        maintenanceService.scheduleUpsMaintenance(maintenance);
        String action = maintenance.getMaintenanceId() != null ? "updated" : "saved";
        redirectAttributes.addFlashAttribute("success", "UPS maintenance record " + action + " successfully");
        return "redirect:/maintenance";
    }

    @PostMapping("/ups/delete/{id}")
    public String deleteUpsMaintenance(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        maintenanceService.getUpsMaintenanceById(id).ifPresent(m -> {
            // Delete associated service report file
            if (m.getServiceReportPath() != null && !m.getServiceReportPath().isBlank()) {
                fileStorageService.deleteFile(m.getServiceReportPath());
            }
        });
        maintenanceService.deleteUpsMaintenance(id);
        redirectAttributes.addFlashAttribute("success", "UPS maintenance record deleted successfully");
        return "redirect:/maintenance";
    }

    // ==================== Cooling Maintenance CRUD ====================

    @GetMapping("/cooling/new")
    public String showCoolingMaintenanceForm(Model model) {
        model.addAttribute("coolingMaintenance", new CoolingMaintenance());
        model.addAttribute("isEdit", false);
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
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
                                          RedirectAttributes redirectAttributes) {
        // Handle file upload
        if (serviceReportFile != null && !serviceReportFile.isEmpty()) {
            String filePath = fileStorageService.storeServiceReport(serviceReportFile);
            maintenance.setServiceReportPath(filePath);
        } else if (maintenance.getMaintenanceId() != null) {
            // Preserve existing file path on edit if no new file uploaded
            maintenanceService.getCoolingMaintenanceById(maintenance.getMaintenanceId())
                    .ifPresent(existing -> {
                        if (maintenance.getServiceReportPath() == null || maintenance.getServiceReportPath().isBlank()) {
                            maintenance.setServiceReportPath(existing.getServiceReportPath());
                        }
                    });
        }

        maintenanceService.scheduleCoolingMaintenance(maintenance);
        String action = maintenance.getMaintenanceId() != null ? "updated" : "saved";
        redirectAttributes.addFlashAttribute("success", "Cooling maintenance record " + action + " successfully");
        return "redirect:/maintenance";
    }

    @PostMapping("/cooling/delete/{id}")
    public String deleteCoolingMaintenance(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        maintenanceService.getCoolingMaintenanceById(id).ifPresent(m -> {
            if (m.getServiceReportPath() != null && !m.getServiceReportPath().isBlank()) {
                fileStorageService.deleteFile(m.getServiceReportPath());
            }
        });
        maintenanceService.deleteCoolingMaintenance(id);
        redirectAttributes.addFlashAttribute("success", "Cooling maintenance record deleted successfully");
        return "redirect:/maintenance";
    }

    // ==================== Quarterly Scheduling ====================

    @PostMapping("/ups/schedule-quarterly")
    public String scheduleQuarterlyUps(@RequestParam Long upsId,
                                        @RequestParam String technician,
                                        @RequestParam String vendor,
                                        RedirectAttributes redirectAttributes) {
        maintenanceService.scheduleQuarterlyUpsMaintenance(upsId, technician, vendor);
        redirectAttributes.addFlashAttribute("success", "Quarterly UPS maintenance scheduled successfully");
        return "redirect:/maintenance";
    }

    // ==================== Service Report Download ====================

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

    // ==================== Maintenance Report ====================

    @GetMapping("/report")
    public String maintenanceReport(Model model) {
        // Statistics
        model.addAttribute("totalUps", maintenanceService.getTotalUpsMaintenanceCount());
        model.addAttribute("totalCooling", maintenanceService.getTotalCoolingMaintenanceCount());
        model.addAttribute("upsPreventive", maintenanceService.getUpsPreventiveCount());
        model.addAttribute("upsCorrective", maintenanceService.getUpsCorrectiveCount());
        model.addAttribute("coolingPreventive", maintenanceService.getCoolingPreventiveCount());
        model.addAttribute("coolingCorrective", maintenanceService.getCoolingCorrectiveCount());

        // Overdue & upcoming
        model.addAttribute("overdueUps", maintenanceService.getOverdueUpsMaintenance());
        model.addAttribute("overdueCooling", maintenanceService.getOverdueCoolingMaintenance());
        model.addAttribute("upcomingUps", maintenanceService.getUpcomingUpsMaintenance());
        model.addAttribute("upcomingCooling", maintenanceService.getUpcomingCoolingMaintenance());

        // All records for the table
        model.addAttribute("allUpsMaintenance", maintenanceService.getAllUpsMaintenance());
        model.addAttribute("allCoolingMaintenance", maintenanceService.getAllCoolingMaintenance());

        return "maintenance/report";
    }

    // ==================== Generate Reminders Manually ====================

    @PostMapping("/generate-reminders")
    public String generateReminders(RedirectAttributes redirectAttributes) {
        int count = reminderService.generateRemindersNow();
        redirectAttributes.addFlashAttribute("success",
                count + " maintenance reminder(s) generated and sent to the Alerts module");
        return "redirect:/maintenance";
    }
}
