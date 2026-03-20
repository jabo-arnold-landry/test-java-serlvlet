package com.spcms.controllers;

import com.spcms.models.DecisionRequest;
import com.spcms.models.User;
import com.spcms.services.CoolingService;
import com.spcms.services.DecisionRequestService;
import com.spcms.services.EquipmentService;
import com.spcms.services.UpsService;
import com.spcms.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;

@Controller
@RequestMapping("/decisions")
public class DecisionRequestController {

    @Autowired
    private DecisionRequestService decisionRequestService;

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private UpsService upsService;

    @Autowired
    private CoolingService coolingService;

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("decisions", decisionRequestService.getAll());
        model.addAttribute("pending", decisionRequestService.getPending());
        return "decisions/list";
    }

    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("decision", new DecisionRequest());
        loadReferenceData(model);
        return "decisions/form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute DecisionRequest decision,
                       Authentication authentication,
                       RedirectAttributes redirectAttributes) {
        normalizeReferences(decision);
        if (decision.getDecisionId() != null) {
            DecisionRequest existing = decisionRequestService.getById(decision.getDecisionId())
                    .orElseThrow(() -> new RuntimeException("Decision request not found"));
            existing.setRequestType(decision.getRequestType());
            existing.setTitle(decision.getTitle());
            existing.setDescription(decision.getDescription());
            existing.setAmount(decision.getAmount());
            existing.setEquipment(decision.getEquipment());
            existing.setUps(decision.getUps());
            existing.setCoolingUnit(decision.getCoolingUnit());
            if (decision.getRequestedBy() != null && decision.getRequestedBy().getUserId() != null) {
                existing.setRequestedBy(decision.getRequestedBy());
            }
            decisionRequestService.update(existing);
            redirectAttributes.addFlashAttribute("success", "Decision request updated");
            return "redirect:/decisions";
        }

        if (decision.getRequestedBy() == null || decision.getRequestedBy().getUserId() == null) {
            User currentUser = userService.getUserByUsername(authentication.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));
            decision.setRequestedBy(currentUser);
        }
        decisionRequestService.create(decision);
        redirectAttributes.addFlashAttribute("success", "Decision request submitted");
        return "redirect:/decisions";
    }

    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("decision", decisionRequestService.getById(id)
                .orElseThrow(() -> new RuntimeException("Decision request not found")));
        loadReferenceData(model);
        return "decisions/form";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("decision", decisionRequestService.getById(id)
                .orElseThrow(() -> new RuntimeException("Decision request not found")));
        return "decisions/view";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        decisionRequestService.delete(id);
        redirectAttributes.addFlashAttribute("success", "Decision request deleted");
        return "redirect:/decisions";
    }

    @PostMapping("/approve/{id}")
    public String approve(@PathVariable Long id,
                          @RequestParam(required = false) String remarks,
                          Authentication authentication,
                          RedirectAttributes redirectAttributes) {
        User currentUser = userService.getUserByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        decisionRequestService.approve(id, currentUser.getUserId(), remarks);
        redirectAttributes.addFlashAttribute("success", "Decision request approved");
        return "redirect:/decisions";
    }

    @PostMapping("/reject/{id}")
    public String reject(@PathVariable Long id,
                         @RequestParam String remarks,
                         Authentication authentication,
                         RedirectAttributes redirectAttributes) {
        User currentUser = userService.getUserByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        decisionRequestService.reject(id, currentUser.getUserId(), remarks);
        redirectAttributes.addFlashAttribute("success", "Decision request rejected");
        return "redirect:/decisions";
    }

    @GetMapping("/report")
    public String report(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end,
                         @RequestParam(required = false) DecisionRequest.DecisionStatus status,
                         @RequestParam(required = false) DecisionRequest.RequestType type,
                         Model model) {
        model.addAttribute("decisions", decisionRequestService.getReport(start, end, status, type));
        model.addAttribute("start", start);
        model.addAttribute("end", end);
        model.addAttribute("status", status);
        model.addAttribute("type", type);
        return "decisions/report";
    }

    private void loadReferenceData(Model model) {
        model.addAttribute("equipmentList", equipmentService.getAllEquipment());
        model.addAttribute("upsList", upsService.getAllUps());
        model.addAttribute("coolingList", coolingService.getAllCoolingUnits());
        model.addAttribute("users", userService.getAllUsers());
    }

    private void normalizeReferences(DecisionRequest decision) {
        if (decision.getEquipment() != null && decision.getEquipment().getEquipmentId() == null) {
            decision.setEquipment(null);
        }
        if (decision.getUps() != null && decision.getUps().getUpsId() == null) {
            decision.setUps(null);
        }
        if (decision.getCoolingUnit() != null && decision.getCoolingUnit().getCoolingId() == null) {
            decision.setCoolingUnit(null);
        }
        if (decision.getRequestedBy() != null && decision.getRequestedBy().getUserId() == null) {
            decision.setRequestedBy(null);
        }
    }
}
