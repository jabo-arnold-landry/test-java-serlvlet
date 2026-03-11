package com.spcms.controllers;

import com.spcms.models.Visitor;
import com.spcms.services.VisitorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;

@Controller
@RequestMapping("/visitors")
public class VisitorController {

    @Autowired
    private VisitorService visitorService;

    @Autowired
    private com.spcms.repositories.VisitApprovalRepository visitApprovalRepository;

    @Autowired
    private com.spcms.repositories.UserRepository userRepository;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("visitors", visitorService.getAllVisitors());
        model.addAttribute("activeVisitors", visitorService.getActiveVisitors());
        model.addAttribute("pendingApprovals", visitorService.getPendingApprovals());
        model.addAttribute("waitingForCheckIn", visitorService.getWaitingForCheckIn());
        
        // Fetch users to populate the escort dropdown
        model.addAttribute("staffList", userRepository.findAll());
        
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
                          @RequestParam(required = false, defaultValue = "1") Integer durationHours,
                          RedirectAttributes redirectAttributes) {
        visitorService.approveVisit(approvalId, managerId, durationHours);
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

    @GetMapping("/dashboard")
    public String dashboard(@RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate startDate,
                            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate endDate,
                            Model model) {
        if (startDate == null) startDate = java.time.LocalDate.now().minusDays(30);
        if (endDate == null) endDate = java.time.LocalDate.now();
        
        List<com.spcms.models.VisitorCheckInOut> active = visitorService.getActiveVisitors();
        List<com.spcms.models.VisitorCheckInOut> overstayed = visitorService.getOverstayedVisitors();
        List<com.spcms.models.VisitorCheckInOut> history = visitorService.getVisitHistory(startDate, endDate);
        List<Object[]> highFrequency = visitorService.getHighFrequencyVisitors();
        
        // Calculate durations for active visitors for the view
        java.util.Map<Long, String> durationStrings = new java.util.HashMap<>();
        for(com.spcms.models.VisitorCheckInOut v : active) {
            if(v.getCheckInTime() != null) {
                java.time.Duration d = java.time.Duration.between(v.getCheckInTime(), java.time.LocalDateTime.now());
                durationStrings.put(v.getCheckId(), String.format("%dh %dm", d.toHours(), d.toMinutesPart()));
            }
        }
        
        model.addAttribute("activeVisitors", active);
        model.addAttribute("overstayedVisitors", overstayed);
        model.addAttribute("visitHistory", history);
        model.addAttribute("highFrequencyVisitors", highFrequency);
        model.addAttribute("durationStrings", durationStrings);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        
        return "visitors/dashboard";
    }
}
