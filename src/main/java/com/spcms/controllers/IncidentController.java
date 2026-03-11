package com.spcms.controllers;

import com.spcms.models.Incident;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import com.spcms.services.IncidentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/incidents")
public class IncidentController {

    @Autowired
    private IncidentService incidentService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("incidents", incidentService.getAllIncidents());
        model.addAttribute("openCount",
                incidentService.getIncidentsByStatus(Incident.IncidentStatus.OPEN).size());
        return "incidents/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("incident", new Incident());
        return "incidents/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Incident incident,
                       Authentication authentication,
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

        incidentService.logIncident(incident);
        redirectAttributes.addFlashAttribute("success", "Incident logged successfully");
        return "redirect:/incidents";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("incident", incidentService.getIncidentById(id)
                .orElseThrow(() -> new RuntimeException("Incident not found")));
        return "incidents/view";
    }

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
                          RedirectAttributes redirectAttributes) {
        incidentService.resolveIncident(id, rootCause, actionTaken);
        redirectAttributes.addFlashAttribute("success", "Incident resolved");
        return "redirect:/incidents";
    }

    @PostMapping("/assign/{id}")
    public String assign(@PathVariable Long id,
                         @RequestParam Long assigneeId,
                         RedirectAttributes redirectAttributes) {
        incidentService.assignIncident(id, assigneeId);
        redirectAttributes.addFlashAttribute("success", "Incident assigned");
        return "redirect:/incidents";
    }
}
