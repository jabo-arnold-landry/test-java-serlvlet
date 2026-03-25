package com.spcms.controllers;

import com.spcms.models.Incident;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.IncidentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/incidents")
public class IncidentController {

    private static final Logger log = LoggerFactory.getLogger(IncidentController.class);
    @Autowired
    private IncidentService incidentService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.spcms.services.UserService userService;

    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;

    @org.springframework.web.bind.annotation.InitBinder
    public void initBinder(org.springframework.web.bind.WebDataBinder binder) {
        // Convert empty strings to null to fix empty datetime/number parsing on submit
        binder.registerCustomEditor(String.class, new org.springframework.beans.propertyeditors.StringTrimmerEditor(true));
    }

    // ==================== LIST ====================

    @GetMapping
    public String list(Model model) {
        model.addAttribute("incidents", incidentService.getAllIncidents());
        model.addAttribute("openCount",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.OPEN).size());
        return "incidents/list";
    }

    // ==================== INCIDENT REPORT ====================

    @GetMapping("/report")
    public String incidentReport(
            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate date,
            Model model) {
        LocalDate reportDate = (date != null) ? date : LocalDate.now();
        LocalDateTime dayStart = reportDate.atStartOfDay();
        LocalDateTime dayEnd = reportDate.atTime(LocalTime.MAX);

        // All incidents for the selected date
        List<Incident> todayIncidents = incidentService.getIncidentsForDate(dayStart, dayEnd);
        model.addAttribute("todayIncidents", todayIncidents);

        // Resolved incidents for the selected date
        List<Incident> resolvedIncidents = incidentService.getResolvedIncidentsForDate(dayStart, dayEnd);
        model.addAttribute("resolvedIncidents", resolvedIncidents);

        // Incidents grouped by equipment type (department)
        List<Object[]> byDepartment = incidentService.getIncidentCountByEquipmentType(dayStart, dayEnd);
        model.addAttribute("byDepartment", byDepartment);

        // Total downtime
        Integer totalDowntime = incidentService.getTotalDowntimeMinutes(dayStart, dayEnd);
        model.addAttribute("totalDowntime", totalDowntime);

        // Summary counts
        model.addAttribute("totalCount", todayIncidents.size());
        model.addAttribute("resolvedCount", resolvedIncidents.size());
        model.addAttribute("openCount",
                todayIncidents.stream().filter(i -> i.getStatus() == Incident.IncidentStatus.OPEN).count());
        model.addAttribute("inProgressCount",
                todayIncidents.stream().filter(i -> i.getStatus() == Incident.IncidentStatus.IN_PROGRESS).count());
        model.addAttribute("criticalCount",
                todayIncidents.stream().filter(i -> i.getSeverity() == Incident.Severity.CRITICAL).count());

        model.addAttribute("selectedDate", reportDate);

        return "incidents/report";
    }

    // ==================== CREATE ====================

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("incident", new Incident());
        model.addAttribute("isEdit", false);
        return "incidents/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Incident incident,
                       Authentication authentication,
                      
            org.springframework.validation.BindingResult result,
            @RequestParam(value = "attachmentFile", required = false) MultipartFile attachmentFile,
            RedirectAttributes redirectAttributes) {
        // Prefer logged-in user as reporter; fallback to provided ID if valid
        if (authentication != null) {
            userRepository.findByUsername(authentication.getName())
                    .ifPresent(incident::setReportedBy);
        } else if (incident.getReportedBy() != null && incident.getReportedBy().getUserId() != null) {
            Long reportedById = incident.getReportedBy().getUserId();
            userRepository.findById(reportedById)
                    .ifPresentOrElse(incident::setReportedBy, () -> incident.setReportedBy(null));
        }

        
        if (result.hasErrors()) {
            StringBuilder errors = new StringBuilder("Form data errors: ");
            result.getAllErrors().forEach(e -> errors.append(e.getDefaultMessage()).append("; "));
            redirectAttributes.addFlashAttribute("error", errors.toString());
            // Since it's a redirect to list, the invalid data is lost, but user sees error.
            return "redirect:/incidents";
        }
        
        try {
            log.info("Saving incident - title: {}, hasAttachment: {}",
                    incident.getTitle(),
                    (attachmentFile != null && !attachmentFile.isEmpty()));
            handleFileUpload(attachmentFile, incident);
            log.info("Before save - attachmentPath: {}", incident.getAttachmentPath());
            incidentService.logIncident(incident);
            redirectAttributes.addFlashAttribute("success", "Incident logged successfully!");
        } catch (Exception e) {
            log.error("Error saving incident: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("error", "Error saving incident: " + e.getMessage());
        }
        return "redirect:/incidents";
    }

    // ==================== VIEW ====================

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("incident", incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found")));
        model.addAttribute("technicians", userService.getUsersByRole(com.spcms.models.User.Role.TECHNICIAN));
        return "incidents/view";
    }

    // ==================== EDIT ====================

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        Incident incident = incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));
        model.addAttribute("incident", incident);
        model.addAttribute("isEdit", true);
        return "incidents/form";
    }

    @PostMapping("/update/{id}")
    public String update(@PathVariable Long id,
            @ModelAttribute Incident incident,
            org.springframework.validation.BindingResult result,
            @RequestParam(value = "attachmentFile", required = false) MultipartFile attachmentFile,
            RedirectAttributes redirectAttributes) {
        
        if (result.hasErrors()) {
            StringBuilder errors = new StringBuilder("Form data errors: ");
            result.getAllErrors().forEach(e -> errors.append(e.getDefaultMessage()).append("; "));
            redirectAttributes.addFlashAttribute("error", errors.toString());
            return "redirect:/incidents/edit/" + id;
        }

        try {
            // Keep existing attachment if no new file uploaded
            Incident existing = incidentService.getIncidentById(id)
                    .orElseThrow(() -> new RuntimeException("Incident not found"));
            if (attachmentFile == null || attachmentFile.isEmpty()) {
                incident.setAttachmentPath(existing.getAttachmentPath());
            } else {
                handleFileUpload(attachmentFile, incident);
            }
            incident.setIncidentId(id);
            incident.setCreatedAt(existing.getCreatedAt());
            incidentService.logIncident(incident);
            redirectAttributes.addFlashAttribute("success", "Incident updated successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Error updating incident: " + e.getMessage());
        }
        return "redirect:/incidents/view/" + id;
    }

    // ==================== DELETE ====================

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        incidentService.deleteIncident(id);
        redirectAttributes.addFlashAttribute("success", "Incident deleted successfully.");
        return "redirect:/incidents";
    }

    // ==================== STATUS ACTIONS ====================

    @GetMapping("/assign/{id}")
    public String assignRedirect(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        redirectAttributes.addFlashAttribute("info", "Use the Assign form on the incident page.");
        return "redirect:/incidents/view/" + id;
    }

    @GetMapping("/resolve/{id}")
    public String resolveRedirect(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        redirectAttributes.addFlashAttribute("info", "Assign the incident first to enable resolution.");
        return "redirect:/incidents/view/" + id;
    }

    @PostMapping("/resolve/{id}")
    public String resolve(@PathVariable Long id,
            @RequestParam String rootCause,
            @RequestParam String actionTaken,
            @RequestParam(required = false) Long resolverId,
            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime downtimeStart,
            @RequestParam(required = false) Incident.IncidentStatus newStatus,
            RedirectAttributes redirectAttributes,
            jakarta.servlet.http.HttpServletRequest request,
            java.security.Principal principal) {
        if (!request.isUserInRole("TECHNICIAN")) {
            redirectAttributes.addFlashAttribute("error", "Only technicians can resolve incidents.");
            return "redirect:/incidents/view/" + id;
        }
        com.spcms.models.User resolver;
        if (resolverId != null) {
            resolver = userService.getUserById(resolverId).orElse(null);
        } else {
            resolver = userService.getUserByUsername(principal.getName())
                    .orElseThrow(() -> new RuntimeException("Resolver missing"));
        }
        
        Long finalResolverId = (resolver != null) ? resolver.getUserId() : null;
        incidentService.resolveIncident(id, rootCause, actionTaken, finalResolverId, downtimeStart, newStatus);
        redirectAttributes.addFlashAttribute("success", "Incident status updated successfully!");
        return "redirect:/incidents/view/" + id;
    }

    @PostMapping("/assign/{id}")
    public String assign(@PathVariable Long id,
            @RequestParam Long assigneeId,
            RedirectAttributes redirectAttributes,
            jakarta.servlet.http.HttpServletRequest request) {
        if (!request.isUserInRole("TECHNICIAN")) {
            redirectAttributes.addFlashAttribute("error", "Only technicians can assign incidents.");
            return "redirect:/incidents/view/" + id;
        }
        incidentService.assignIncident(id, assigneeId);
        redirectAttributes.addFlashAttribute("success", "Incident assigned successfully!");
        return "redirect:/incidents/view/" + id;
    }

    // ==================== HELPER ====================

    private void handleFileUpload(MultipartFile file, Incident incident) {
        if (file == null || file.isEmpty()) {
            log.debug("No attachment file provided or file is empty");
            return;
        }
        try {
            log.info("Uploading file: {} (size: {} bytes, type: {})",
                    file.getOriginalFilename(), file.getSize(), file.getContentType());

            // Resolve to absolute path so it works with external Tomcat
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize().resolve("incidents");
            Files.createDirectories(uploadPath);
            log.info("Upload directory resolved to: {}", uploadPath);

            String originalName = file.getOriginalFilename();
            String ext = (originalName != null && originalName.contains("."))
                    ? originalName.substring(originalName.lastIndexOf("."))
                    : "";
            String fileName = UUID.randomUUID() + ext;
            Path filePath = uploadPath.resolve(fileName);

            // Use Files.copy for more reliable file transfer
            Files.copy(file.getInputStream(), filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);

            String attachmentUrl = "/uploads/incidents/" + fileName;
            incident.setAttachmentPath(attachmentUrl);
            log.info("File uploaded successfully: {} -> DB path: {}", filePath, attachmentUrl);
        } catch (IOException e) {
            log.error("Failed to upload file: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to upload file: " + e.getMessage(), e);
        }
    }
}
