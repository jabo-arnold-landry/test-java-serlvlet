package com.spcms.controllers;

import com.spcms.models.Visitor;
import com.spcms.services.VisitorService;
import com.spcms.services.IncidentService;
import com.spcms.models.Incident;
import com.spcms.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.security.Principal;
import java.util.List;

@Controller
@RequestMapping("/visitors")
public class VisitorController {

    @Autowired
    private VisitorService visitorService;

    @Autowired
    private IncidentService incidentService;

    @Autowired
    private com.spcms.repositories.VisitApprovalRepository visitApprovalRepository;

    @Autowired
    private com.spcms.repositories.UserRepository userRepository;

    @Autowired
    private com.spcms.repositories.VisitorDeletionLogRepository visitorDeletionLogRepository;

    @GetMapping
    public String list(@RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate startDate,
                       @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) java.time.LocalDate endDate,
                       Principal principal,
                       Model model) {
        
        if (startDate == null) startDate = java.time.LocalDate.now().minusDays(30);
        if (endDate == null) endDate = java.time.LocalDate.now();
        // Effectively-final copies required for use inside lambda expressions
        final java.time.LocalDate finalStart = startDate;
        final java.time.LocalDate finalEnd = endDate;

        // Active visitors
        List<com.spcms.models.VisitorCheckInOut> active = new java.util.ArrayList<>();
        try { active = visitorService.getActiveVisitors(); } catch (Exception e) { System.err.println("WARN: getActiveVisitors failed: " + e.getMessage()); }
        
        model.addAttribute("visitors", safeGet(() -> visitorService.getAllVisitors()));
        model.addAttribute("activeVisitors", active);
        model.addAttribute("pendingApprovals", safeGet(() -> visitorService.getPendingApprovals()));
        model.addAttribute("waitingForCheckIn", safeGet(() -> visitorService.getWaitingForCheckIn()));
        model.addAttribute("staffList", safeGet(() -> userRepository.findAll()));
        
        // Dashboard specific
        model.addAttribute("overstayedVisitors", safeGet(() -> visitorService.getOverstayedVisitors()));
        model.addAttribute("visitHistory", safeGet(() -> visitorService.getVisitHistory(finalStart, finalEnd)));
        model.addAttribute("highFrequencyVisitors", safeGet(() -> visitorService.getHighFrequencyVisitors()));

        // Technician Specific
        model.addAttribute("approvedVisitsToday", safeGet(() -> visitorService.getApprovedVisitsToday()));
        model.addAttribute("completedTodayCount", safeGetLong(() -> visitorService.countCompletedVisitsToday()));
        
        // Admin Intelligence Stats
        List<Incident> incidents = safeGet(() -> incidentService.getAllIncidents());
        model.addAttribute("allIncidents", incidents);
        
        List<Visitor> allVisitors = safeGet(() -> visitorService.getAllVisitors());
        model.addAttribute("visitors", allVisitors);
        model.addAttribute("totalVisitorsCount", (long) (allVisitors != null ? allVisitors.size() : 0));
        
        // Aggregate monthly stats for trends
        java.util.Map<String, Long> monthlyStats = new java.util.LinkedHashMap<>();
        java.time.YearMonth currentMonth = java.time.YearMonth.now();
        if (allVisitors != null) {
            for (int i = 5; i >= 0; i--) {
                java.time.YearMonth targetMonth = currentMonth.minusMonths(i);
                String monthName = targetMonth.getMonth().getDisplayName(java.time.format.TextStyle.SHORT, java.util.Locale.ENGLISH);
                long count = allVisitors.stream()
                    .filter(v -> v.getVisitDate() != null && java.time.YearMonth.from(v.getVisitDate()).equals(targetMonth))
                    .count();
                monthlyStats.put(monthName, count);
            }
        }
        model.addAttribute("monthlyStats", monthlyStats);

        java.util.Map<String, String> durationStrings = new java.util.HashMap<>();
        java.util.Map<String, String> checkInTimes = new java.util.HashMap<>();
        java.util.Map<String, String> checkOutTimes = new java.util.HashMap<>();
        java.time.format.DateTimeFormatter timeFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");

        for(com.spcms.models.VisitorCheckInOut v : active) {
            if(v.getCheckInTime() != null) {
                java.time.Duration d = java.time.Duration.between(v.getCheckInTime(), java.time.LocalDateTime.now());
                long hours = d.toHours();
                long minutes = d.toMinutes() % 60; // Java 8 compatible
                durationStrings.put(String.valueOf(v.getCheckId()), String.format("%dh %dm", hours, minutes));
                checkInTimes.put(String.valueOf(v.getCheckId()), v.getCheckInTime().format(timeFmt));
            }
            if(v.getCheckOutTime() != null) {
                checkOutTimes.put(String.valueOf(v.getCheckId()), v.getCheckOutTime().format(timeFmt));
            }
        }

        List<com.spcms.models.VisitorCheckInOut> history = safeGet(() -> visitorService.getVisitHistory(finalStart, finalEnd));
        for(com.spcms.models.VisitorCheckInOut h : history) {
            if(h.getCheckInTime() != null) checkInTimes.put(String.valueOf(h.getCheckId()), h.getCheckInTime().format(timeFmt));
            if(h.getCheckOutTime() != null) checkOutTimes.put(String.valueOf(h.getCheckId()), h.getCheckOutTime().format(timeFmt));
        }

        List<com.spcms.models.VisitApproval> decisionHistory = safeGet(() -> visitorService.getHistoricalApprovals());
        java.util.Map<String, String> decisionTimes = new java.util.HashMap<>();
        for(com.spcms.models.VisitApproval da : decisionHistory) {
            if(da.getDecisionTime() != null) decisionTimes.put(String.valueOf(da.getApprovalId()), da.getDecisionTime().format(timeFmt));
        }

        java.time.format.DateTimeFormatter csvDateFmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
        java.time.format.DateTimeFormatter csvDateTimeFmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        
        java.time.format.DateTimeFormatter fullDateFmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy");
        java.util.Map<String, String> incidentDates = new java.util.HashMap<>();
        java.util.Map<String, String> incidentCsvDates = new java.util.HashMap<>();
        for(Incident inc : incidents) {
            if(inc.getCreatedAt() != null) {
                incidentDates.put(String.valueOf(inc.getIncidentId()), inc.getCreatedAt().format(fullDateFmt));
                incidentCsvDates.put(String.valueOf(inc.getIncidentId()), inc.getCreatedAt().format(csvDateFmt));
            }
        }

        java.time.format.DateTimeFormatter detailTimeFmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM, HH:mm");
        java.util.Map<String, String> historyCheckInTimes = new java.util.HashMap<>();
        java.util.Map<String, String> historyCheckOutTimes = new java.util.HashMap<>();
        java.util.Map<String, String> historyCsvIn = new java.util.HashMap<>();
        java.util.Map<String, String> historyCsvOut = new java.util.HashMap<>();
        
        for(com.spcms.models.VisitorCheckInOut h : history) {
            if(h.getCheckInTime() != null) {
                historyCheckInTimes.put(String.valueOf(h.getCheckId()), h.getCheckInTime().format(detailTimeFmt));
                historyCsvIn.put(String.valueOf(h.getCheckId()), h.getCheckInTime().format(csvDateTimeFmt));
            }
            if(h.getCheckOutTime() != null) {
                historyCheckOutTimes.put(String.valueOf(h.getCheckId()), h.getCheckOutTime().format(detailTimeFmt));
                historyCsvOut.put(String.valueOf(h.getCheckId()), h.getCheckOutTime().format(csvDateTimeFmt));
            }
        }

        model.addAttribute("incidentDates", incidentDates);
        model.addAttribute("incidentCsvDates", incidentCsvDates);
        model.addAttribute("historyCheckInTimes", historyCheckInTimes);
        model.addAttribute("historyCheckOutTimes", historyCheckOutTimes);
        model.addAttribute("historyCsvIn", historyCsvIn);
        model.addAttribute("historyCsvOut", historyCsvOut);
        model.addAttribute("durationStrings", durationStrings);
        model.addAttribute("checkInTimes", checkInTimes);
        model.addAttribute("checkOutTimes", checkOutTimes);
        model.addAttribute("decisionHistory", decisionHistory);
        model.addAttribute("decisionTimes", decisionTimes);
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        java.util.Map<String, String> deletionDates = new java.util.HashMap<>();
        List<com.spcms.models.VisitorDeletionLog> dLog = safeGet(() -> visitorDeletionLogRepository.findAllByOrderByDeletedAtDesc());
        for(com.spcms.models.VisitorDeletionLog l : dLog) {
            if(l.getDeletedAt() != null) deletionDates.put(String.valueOf(l.getId()), l.getDeletedAt().format(detailTimeFmt));
        }

        model.addAttribute("deletionLog", dLog);
        model.addAttribute("deletionDates", deletionDates);
        
        return "visitors/list";
    }

    private <T> java.util.List<T> safeGet(java.util.concurrent.Callable<java.util.List<T>> supplier) {
        try { return supplier.call(); } catch (Exception e) {
            System.err.println("WARN: Query failed: " + e.getMessage());
            return new java.util.ArrayList<>();
        }
    }

    private long safeGetLong(java.util.concurrent.Callable<Long> supplier) {
        try { return supplier.call(); } catch (Exception e) {
            System.err.println("WARN: Count query failed: " + e.getMessage());
            return 0L;
        }
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
                          @RequestParam(required = false, defaultValue = "1") Integer durationHours,
                          Principal principal,
                          RedirectAttributes redirectAttributes) {
        userRepository.findByUsername(principal.getName()).ifPresent(manager -> {
            visitorService.approveVisit(approvalId, manager.getUserId(), durationHours);
        });
        redirectAttributes.addFlashAttribute("success", "Visit approved");
        return "redirect:/visitors";
    }

    @PostMapping("/reject/{approvalId}")
    public String reject(@PathVariable Long approvalId,
                         @RequestParam String reason,
                         Principal principal,
                         RedirectAttributes redirectAttributes) {
        userRepository.findByUsername(principal.getName()).ifPresent(manager -> {
            visitorService.rejectVisit(approvalId, manager.getUserId(), reason);
        });
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
                           @RequestParam(required = false, defaultValue = "false") boolean badgeReturned,
                           RedirectAttributes redirectAttributes) {
        visitorService.checkOut(checkId, equipmentConfirmed, badgeReturned);
        redirectAttributes.addFlashAttribute("success", "Visitor checked out");
        return "redirect:/visitors";
    }

    @PostMapping("/incident")
    public String reportIncident(@RequestParam String type,
                                 @RequestParam String description,
                                 Principal principal,
                                 RedirectAttributes redirectAttributes) {
        System.out.println("DEBUG: Incident report received for: " + type);
        try {
            if (principal == null || principal.getName() == null) {
                redirectAttributes.addFlashAttribute("error", "Session expired or user not found. Please re-login.");
                return "redirect:/login";
            }
            
            String username = principal.getName();
            com.spcms.models.User user = userRepository.findByUsername(username).orElse(null);
            
            if (user == null) {
                System.err.println("DEBUG ERROR: Logged-in user '" + username + "' not found in database.");
                redirectAttributes.addFlashAttribute("error", "Logged-in user not found in database.");
                return "redirect:/visitors";
            }

            com.spcms.models.Incident incident = new com.spcms.models.Incident();
            incident.setTitle("Visitor Incident: " + type);
            incident.setDescription(description);
            incident.setEquipmentType(com.spcms.models.Incident.EquipmentType.OTHER);
            incident.setSeverity(com.spcms.models.Incident.Severity.MEDIUM);
            incident.setReportedBy(user);
            incident.setStatus(com.spcms.models.Incident.IncidentStatus.OPEN);
            
            System.out.println("DEBUG: Saving incident entity...");
            visitorService.saveIncident(incident);
            System.out.println("DEBUG: Incident saved successfully.");
            
            redirectAttributes.addFlashAttribute("success", "Incident reported successfully");
        } catch (Throwable e) {
            String errorMsg = "System Error: " + (e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName());
            System.err.println("INCIDENT SAVE CRITICAL ERROR: " + errorMsg);
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", errorMsg);
        }
        return "redirect:/visitors";
    }

}
