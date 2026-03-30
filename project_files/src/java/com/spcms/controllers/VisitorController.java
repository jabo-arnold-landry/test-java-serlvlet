package com.spcms.controllers;

import com.spcms.models.Visitor;
import com.spcms.services.VisitorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/visitors")
public class VisitorController {

    @Autowired
    private VisitorService visitorService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("visitors", visitorService.getAllVisitors());
        model.addAttribute("activeVisitors", visitorService.getActiveVisitors());
        model.addAttribute("pendingApprovals", visitorService.getPendingApprovals());
        return "visitors/list";
    }

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        model.addAttribute("visitor", new Visitor());
        return "visitors/register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute Visitor visitor, RedirectAttributes redirectAttributes) {
        Visitor saved = visitorService.registerVisitor(visitor);
        visitorService.submitForApproval(saved.getVisitorId());
        redirectAttributes.addFlashAttribute("success", "Visitor registered. Pass: " + saved.getPassNumber());
        return "redirect:/visitors";
    }

    @PostMapping("/approve/{approvalId}")
    public String approve(@PathVariable Long approvalId,
                          @RequestParam Long managerId,
                          RedirectAttributes redirectAttributes) {
        visitorService.approveVisit(approvalId, managerId);
        redirectAttributes.addFlashAttribute("success", "Visit approved");
        return "redirect:/visitors";
    }

    @PostMapping("/reject/{approvalId}")
    public String reject(@PathVariable Long approvalId,
                         @RequestParam Long managerId,
                         @RequestParam String reason,
                         RedirectAttributes redirectAttributes) {
        visitorService.rejectVisit(approvalId, managerId, reason);
        redirectAttributes.addFlashAttribute("success", "Visit rejected");
        return "redirect:/visitors";
    }

    @PostMapping("/checkin")
    public String checkIn(@RequestParam Long visitorId,
                          @RequestParam String badge,
                          @RequestParam Long escortId,
                          RedirectAttributes redirectAttributes) {
        visitorService.checkIn(visitorId, badge, escortId);
        redirectAttributes.addFlashAttribute("success", "Visitor checked in");
        return "redirect:/visitors";
    }

    @PostMapping("/checkout/{checkId}")
    public String checkOut(@PathVariable Long checkId,
                           @RequestParam boolean equipmentConfirmed,
                           RedirectAttributes redirectAttributes) {
        visitorService.checkOut(checkId, equipmentConfirmed);
        redirectAttributes.addFlashAttribute("success", "Visitor checked out");
        return "redirect:/visitors";
    }
}
