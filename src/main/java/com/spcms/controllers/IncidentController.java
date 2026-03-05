package com.spcms.controllers;

import com.spcms.models.Incident;
import com.spcms.services.IncidentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/incidents")
public class IncidentController {

    @Autowired
    private IncidentService incidentService;

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
    public String save(@ModelAttribute Incident incident, RedirectAttributes redirectAttributes) {
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
