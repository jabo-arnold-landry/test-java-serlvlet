package com.spcms.controllers;

import com.spcms.models.Incident;
import com.spcms.models.User;
import com.spcms.services.IncidentService;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.Authentication;

import org.springframework.format.annotation.DateTimeFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/incidents")
public class IncidentController {

    @Autowired
    private IncidentService incidentService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public String list(Model model, Authentication authentication) {
        model.addAttribute("incidents", incidentService.getAllIncidents());
        model.addAttribute("inProgressCount",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.IN_PROGRESS).size());
        model.addAttribute("showResolved", false);
        model.addAttribute("showInProgress", false);
        model.addAttribute("pageTitle", "Incident Logger");
        model.addAttribute("currentUsername", authentication != null ? authentication.getName() : null);
        model.addAttribute("isAdmin", hasRole(authentication, "ROLE_ADMIN"));
        return "incidents/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("incident", new Incident());
        return "incidents/form";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        Incident incident = incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));
        model.addAttribute("incident", incident);
        model.addAttribute("downtimeStartValue", toDateTimeLocal(incident.getDowntimeStart()));
        model.addAttribute("downtimeEndValue", toDateTimeLocal(incident.getDowntimeEnd()));
        return "incidents/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Incident incident, RedirectAttributes redirectAttributes) {
        incidentService.logIncident(incident);
        redirectAttributes.addFlashAttribute("success", "Incident logged successfully");
        return "redirect:/incidents";
    }

    @PostMapping("/update/{id}")
    public String update(@PathVariable Long id,
                         @ModelAttribute Incident updated,
                         RedirectAttributes redirectAttributes) {
        Incident incident = incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));

        incident.setTitle(updated.getTitle());
        incident.setDescription(updated.getDescription());
        incident.setEquipmentType(updated.getEquipmentType());
        incident.setEquipmentId(updated.getEquipmentId());
        incident.setSeverity(updated.getSeverity());
        incident.setStatus(updated.getStatus());

        if (updated.getDowntimeStart() != null) {
            incident.setDowntimeStart(updated.getDowntimeStart());
        }
        if (updated.getDowntimeEnd() != null) {
            incident.setDowntimeEnd(updated.getDowntimeEnd());
        }

        if (updated.getReportedBy() != null && updated.getReportedBy().getUserId() != null) {
            User reporter = new User();
            reporter.setUserId(updated.getReportedBy().getUserId());
            incident.setReportedBy(reporter);
        }

        incidentService.logIncident(incident);
        redirectAttributes.addFlashAttribute("success", "Incident updated successfully");
        return "redirect:/incidents";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        incidentService.deleteIncident(id);
        redirectAttributes.addFlashAttribute("success", "Incident deleted");
        return "redirect:/incidents";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model, Authentication authentication) {
        Incident incident = incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));
        boolean isAdmin = hasRole(authentication, "ROLE_ADMIN");
        boolean isSolved = incident.getStatus() == Incident.IncidentStatus.RESOLVED;
        boolean canAssign = isAdmin && !isSolved && incident.getAssignedTo() == null;
        model.addAttribute("incident", incident);
        model.addAttribute("users", userRepository.findAll());
        model.addAttribute("canAssign", canAssign);
        model.addAttribute("currentUsername", authentication != null ? authentication.getName() : null);
        model.addAttribute("isAdmin", isAdmin);
        return "incidents/view";
    }

    @PostMapping("/resolve/{id}")
    public String resolve(@PathVariable Long id,
                          @RequestParam String rootCause,
                          @RequestParam String actionTaken,
                          @RequestParam(required = false) String resolvedByUsername,
                          @RequestParam(required = false)
                          @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
                          java.time.LocalDateTime resolvedAt,
                          RedirectAttributes redirectAttributes,
                          Authentication authentication) {
        if (authentication == null) {
            redirectAttributes.addFlashAttribute("error", "Please log in to resolve incidents.");
            return "redirect:/incidents/view/" + id;
        }
        Incident incident = incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found"));
        String currentUsername = authentication.getName();
        if (incident.getAssignedTo() == null
                || !currentUsername.equals(incident.getAssignedTo().getUsername())) {
            redirectAttributes.addFlashAttribute("error", "You can only resolve incidents assigned to you.");
            return "redirect:/incidents/view/" + id;
        }
        try {
            incidentService.resolveIncident(id, rootCause, actionTaken, currentUsername, resolvedAt);
        } catch (IllegalStateException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            return "redirect:/incidents/view/" + id;
        }
        redirectAttributes.addFlashAttribute("success", "Incident resolved");
        return "redirect:/incidents";
    }

    @PostMapping("/assign/{id}")
    public String assign(@PathVariable Long id,
                         @RequestParam String assigneeUsername,
                         RedirectAttributes redirectAttributes,
                         Authentication authentication) {
        if (!hasRole(authentication, "ROLE_ADMIN")) {
            redirectAttributes.addFlashAttribute("error", "Only admins can assign incidents.");
            return "redirect:/incidents/view/" + id;
        }
        User assignee = userRepository.findByUsername(assigneeUsername).orElse(null);
        if (assignee == null) {
            redirectAttributes.addFlashAttribute("error", "User not found: " + assigneeUsername);
            return "redirect:/incidents/view/" + id;
        }
        try {
            incidentService.assignIncident(id, assignee.getUsername());
        } catch (IllegalStateException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            return "redirect:/incidents/view/" + id;
        }
        redirectAttributes.addFlashAttribute("success", "Incident assigned");
        return "redirect:/incidents";
    }

    @GetMapping("/solved")
    public String solved(Model model, Authentication authentication) {
        model.addAttribute("incidents", incidentService.getResolvedIncidents());
        model.addAttribute("showResolved", true);
        model.addAttribute("showInProgress", false);
        model.addAttribute("pageTitle", "Resolved Incidents");
        model.addAttribute("currentUsername", authentication != null ? authentication.getName() : null);
        model.addAttribute("isAdmin", hasRole(authentication, "ROLE_ADMIN"));
        return "incidents/list";
    }

    @GetMapping("/in-progress")
    public String inProgress(Model model, Authentication authentication) {
        model.addAttribute("incidents",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.IN_PROGRESS));
        model.addAttribute("showResolved", false);
        model.addAttribute("showInProgress", true);
        model.addAttribute("pageTitle", "In Progress Incidents");
        model.addAttribute("currentUsername", authentication != null ? authentication.getName() : null);
        model.addAttribute("isAdmin", hasRole(authentication, "ROLE_ADMIN"));
        return "incidents/list";
    }

    @GetMapping("/report")
    public String reportForm() {
        return "incidents/report";
    }

    @PostMapping("/report")
    public String generateReport(
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Model model) {
        if (endDate == null) {
            endDate = startDate;
        }
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.plusDays(1).atStartOfDay().minusNanos(1);

        model.addAttribute("reportStart", startDate);
        model.addAttribute("reportEnd", endDate);
        model.addAttribute("reportIncidents", incidentService.getIncidentsByDateRange(startDateTime, endDateTime));
        model.addAttribute("totalDowntime", incidentService.getTotalDowntimeMinutes(startDateTime, endDateTime));
        model.addAttribute("criticalCount", incidentService.getCriticalIncidentCount(startDateTime, endDateTime));
        return "incidents/report";
    }

    private String toDateTimeLocal(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        String text = value.toString();
        return text.length() >= 16 ? text.substring(0, 16) : text;
    }

    private boolean hasRole(Authentication authentication, String role) {
        if (authentication == null) {
            return false;
        }
        return authentication.getAuthorities().stream()
                .anyMatch(authority -> role.equals(authority.getAuthority()));
    }
}
