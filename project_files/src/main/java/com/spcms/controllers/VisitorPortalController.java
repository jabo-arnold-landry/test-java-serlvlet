package com.spcms.controllers;

import com.spcms.models.User;
import com.spcms.models.Visitor;
import com.spcms.models.VisitApproval;
import com.spcms.models.VisitorCheckInOut;
import com.spcms.models.VisitorDeletionLog;
import com.spcms.services.VisitorService;
import com.spcms.repositories.UserRepository;
import com.spcms.repositories.VisitorRepository;
import com.spcms.repositories.VisitApprovalRepository;
import com.spcms.repositories.VisitorCheckInOutRepository;
import com.spcms.repositories.VisitorDeletionLogRepository;
import com.spcms.models.Incident;
import com.spcms.services.IncidentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

import java.security.Principal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
@RequestMapping("/visitor-portal")
public class VisitorPortalController {

    @Autowired private VisitorService visitorService;
    @Autowired private UserRepository userRepository;
    @Autowired private VisitorRepository visitorRepository;
    @Autowired private VisitApprovalRepository visitApprovalRepository;
    @Autowired private VisitorCheckInOutRepository visitorCheckInOutRepository;
    @Autowired private VisitorDeletionLogRepository visitorDeletionLogRepository;
    @Autowired private IncidentService incidentService;

    private User getCurrentUser(Principal principal) {
        if (principal == null) return null;
        return userRepository.findByUsername(principal.getName()).orElse(null);
    }

    // ==================== DASHBOARD ====================

    @GetMapping
    public String dashboard(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        boolean isTechnician = user.getRole() == User.Role.TECHNICIAN;
        
        boolean isAdmin = user.getRole() == User.Role.ADMIN;
        boolean isManager = user.getRole() == User.Role.MANAGER;
        boolean isSecurity = user.getRole() == User.Role.SECURITY;
        
        long pending = 0;
        long awaiting = 0;
        long activeCount = 0;
        long completed = 0;
        final List<Map<String, Object>> recent = new ArrayList<>();

        if (isTechnician) {
            // TECHNICIAN: Personal Duty Operations (Simplified)
            List<VisitApproval> myAssignments = visitorService.getTechnicianAssignments(user.getUserId());
            List<VisitorCheckInOut> myActive = visitorService.getTechnicianActiveEscorts(user.getUserId());
            List<VisitorCheckInOut> myHistory = visitorService.getTechnicianVisitHistory(user.getUserId());

            awaiting    = myAssignments.size();
            activeCount = myActive.size();
            completed   = myHistory.stream()
                            .filter(v -> v.getCheckOutTime() != null && v.getCheckOutTime().toLocalDate().equals(LocalDate.now()))
                            .count();
            
            // Add Active assignments first
            myActive.stream().limit(3).forEach(v -> {
                recent.add(Map.of(
                    "visitDate",      v.getVisitor().getVisitDate().toString(),
                    "visitorName",    v.getVisitor().getFullName(),
                    "company",        v.getVisitor().getCompany(),
                    "purposeOfVisit", v.getVisitor().getPurposeOfVisit(),
                    "status",         "ACTIVE"
                ));
            });
            // Add Approved assignments
            myAssignments.stream().limit(5 - recent.size()).forEach(a -> {
                recent.add(Map.of(
                    "visitDate",      a.getVisitor().getVisitDate().toString(),
                    "visitorName",    a.getVisitor().getFullName(),
                    "company",        a.getVisitor().getCompany(),
                    "purposeOfVisit", a.getVisitor().getPurposeOfVisit(),
                    "status",         "APPROVED"
                ));
            });

            // Populate dashboard notifications for technician
            List<Map<String, String>> dashNotifications = getTechnicianDashNotifications(user);
            model.addAttribute("dashNotifications", dashNotifications);

        } else if (isManager) {
            // MANAGER: Governance & Approval (Workflow Oversight)
            pending     = (int) visitApprovalRepository.findByStatus(VisitApproval.ApprovalStatus.PENDING).size() +
                          (int) visitApprovalRepository.findByStatus(VisitApproval.ApprovalStatus.MORE_INFO).size();
            awaiting    = visitorService.getWaitingForCheckIn().size();
            activeCount = visitorService.getActiveVisitors().size();
            completed   = visitorService.countCompletedVisitsToday();

            // Duration Statistics
            List<VisitorCheckInOut> allHistory = visitorCheckInOutRepository.findByVisitClosed(true);
            double avgDuration = allHistory.stream()
                .filter(v -> v.getCheckInTime() != null && v.getCheckOutTime() != null)
                .mapToLong(v -> java.time.Duration.between(v.getCheckInTime(), v.getCheckOutTime()).toMinutes())
                .average().orElse(0.0);
            model.addAttribute("avgDuration", String.format("%.1fh", avgDuration / 60.0));

            // Overstay Alerts for Manager
            List<VisitorCheckInOut> overstayed = visitorService.getOverstayedVisitors();
            model.addAttribute("overstayedAlerts", overstayed);

            // Monthly & Daily Stats for Reports
            Map<String, Long> monthlyStats = new LinkedHashMap<>();
            Map<String, Long> dailyStats = new LinkedHashMap<>();
            DateTimeFormatter mFmt = DateTimeFormatter.ofPattern("MMM yyyy");
            DateTimeFormatter dFmt = DateTimeFormatter.ofPattern("dd MMM");
            
            for (int i = 5; i >= 0; i--) {
                YearMonth month = YearMonth.now().minusMonths(i);
                long count = visitorService.getAllVisitors().stream()
                        .filter(v -> v.getVisitDate() != null && YearMonth.from(v.getVisitDate()).equals(month))
                        .count();
                monthlyStats.put(month.format(mFmt), count);
            }
            for (int i = 6; i >= 0; i--) {
                LocalDate date = LocalDate.now().minusDays(i);
                long count = visitorService.getVisitorsByDate(date).size();
                dailyStats.put(date.format(dFmt), count);
            }
            model.addAttribute("monthlyStats", monthlyStats);
            model.addAttribute("dailyStats", dailyStats);

            recent.addAll(visitApprovalRepository.findAll().stream()
                .filter(a -> a.getStatus() == VisitApproval.ApprovalStatus.PENDING || a.getStatus() == VisitApproval.ApprovalStatus.MORE_INFO)
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .limit(5)
                .map(a -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("visitDate",      a.getVisitor().getVisitDate().toString());
                    map.put("visitorName",    a.getVisitor().getFullName());
                    map.put("company",        a.getVisitor().getCompany());
                    map.put("purposeOfVisit", a.getVisitor().getPurposeOfVisit());
                    map.put("nationalId",     a.getVisitor().getNationalIdPassport());
                    map.put("phone",          a.getVisitor().getPhone());
                    map.put("arrivalTime",    a.getVisitor().getArrivalTime() != null ? a.getVisitor().getArrivalTime().toString() : "Not specified");
                    map.put("department",     a.getVisitor().getDepartmentToVisit());
                    map.put("status",         a.getStatus().toString());
                    map.put("approvalId",     a.getApprovalId());
                    map.put("visitorId",      a.getVisitor().getVisitorId());
                    return map;
                })
                .collect(Collectors.toList()));
        } else if (isSecurity) {
            // SECURITY: Receptionist Tracking (Entrance/Exit Traffic)
            pending     = visitorService.getPendingApprovals().size(); // Track approval pipeline
            awaiting    = visitorService.getWaitingForCheckIn().size(); // Ready for check-in
            activeCount = visitorService.getActiveVisitors().size(); // Monitor live
            completed   = visitorService.countCompletedVisitsToday(); // Check-outs

            recent.addAll(visitApprovalRepository.findAll().stream()
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .limit(5)
                .map(a -> {
                    String status = a.getStatus().name();
                    List<VisitorCheckInOut> checks = visitorCheckInOutRepository.findByVisitor_VisitorId(a.getVisitor().getVisitorId());
                    if (checks.stream().anyMatch(v1 -> Boolean.TRUE.equals(v1.getVisitClosed()))) status = "COMPLETED";
                    else if (checks.stream().anyMatch(v1 -> !Boolean.TRUE.equals(v1.getVisitClosed()))) status = "ACTIVE";
                    
                    return Map.<String, Object>of(
                        "visitDate",      a.getVisitor().getVisitDate().toString(),
                        "visitorName",    a.getVisitor().getFullName(),
                        "company",        a.getVisitor().getCompany(),
                        "purposeOfVisit", a.getVisitor().getPurposeOfVisit(),
                        "status",         status
                    );
                })
                .collect(Collectors.toList()));

            // Enable Live Monitoring for Security Dashboard
            List<VisitorCheckInOut> active = visitorService.getActiveVisitors();
            model.addAttribute("activeVisitors", active);
            
            java.util.Map<Long, String> durationMap = new java.util.HashMap<>();
            for (VisitorCheckInOut v : active) {
                if (v.getCheckInTime() != null) {
                    java.time.Duration d = java.time.Duration.between(v.getCheckInTime(), java.time.LocalDateTime.now());
                    durationMap.put(v.getCheckId(), String.format("%dh %dm", d.toHours(), d.toMinutesPart()));
                }
            }
            model.addAttribute("durationMap", durationMap);
            model.addAttribute("overstayedAlerts", visitorService.getOverstayedVisitors());
        } else if (isAdmin) {
            // ADMIN: Intelligence Dashboard (Analytics & Audit)
            model.addAttribute("totalVisitorsCount", (long) visitorService.getAllVisitors().size());

            Map<String, Long> monthlyStats = new LinkedHashMap<>();
            DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("MMM yyyy");
            for (int i = 5; i >= 0; i--) {
                YearMonth month = YearMonth.now().minusMonths(i);
                long count = visitorService.getAllVisitors().stream()
                        .filter(v -> v.getVisitDate() != null && YearMonth.from(v.getVisitDate()).equals(month))
                        .count();
                monthlyStats.put(month.format(monthFormatter), count);
            }
            model.addAttribute("monthlyStats", monthlyStats);

            List<Incident> allIncidents = incidentService.getAllIncidents();
            model.addAttribute("allIncidents", allIncidents);
            
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            Map<Long, String> incidentDates = new HashMap<>();
            allIncidents.forEach(inc -> {
                if(inc.getCreatedAt() != null) incidentDates.put(inc.getIncidentId(), inc.getCreatedAt().format(dtf));
            });
            model.addAttribute("incidentCsvDates", incidentDates);

            List<Object[]> highFreq = visitorService.getHighFrequencyVisitors();
            model.addAttribute("highFrequencyVisitors", highFreq);

            List<VisitorCheckInOut> history = visitorService.getVisitHistory(LocalDate.now().minusDays(30), LocalDate.now());
            model.addAttribute("visitHistory", history);
            
            // System Audit Logs (Latest 10 for dashboard)
            model.addAttribute("systemLogs", visitorService.getLatestActivity(10));
            
            Map<Long, String> historyIn = new HashMap<>();
            Map<Long, String> historyOut = new HashMap<>();
            history.forEach(h -> {
                if(h.getCheckInTime() != null) historyIn.put(h.getCheckId(), h.getCheckInTime().format(dtf));
                if(h.getCheckOutTime() != null) historyOut.put(h.getCheckId(), h.getCheckOutTime().format(dtf));
            });
            model.addAttribute("historyCsvIn", historyIn);
            model.addAttribute("historyCsvOut", historyOut);
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("pendingCount", pending);
        model.addAttribute("awaitingCount", awaiting); 
        model.addAttribute("activeCount", activeCount);
        model.addAttribute("completedCount", completed);
        model.addAttribute("recentVisits", recent);
        model.addAttribute("isAdmin", isAdmin);
        model.addAttribute("isSecurity", isSecurity);
        model.addAttribute("isManager", isManager);
        model.addAttribute("isTechnician", isTechnician);
        
        return "visitor-portal/dashboard";
    }


    // ==================== REGISTER ARRIVAL ====================

    @GetMapping("/request")
    public String requestForm(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        model.addAttribute("currentUser", user);
        model.addAttribute("staffList", userRepository.findAll());
        model.addAttribute("today", LocalDate.now().toString());
        return "visitor-portal/request";
    }

    @PostMapping("/request")
    public String submitRequest(@ModelAttribute Visitor visitor, Principal principal, RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        visitor.setRequestedBy(user);
        Visitor saved = visitorService.registerVisitor(visitor);
        visitorService.submitForApproval(saved.getVisitorId());

        redirectAttributes.addFlashAttribute("success",
            "Visitor registered and sent for approval. Ref: VR-" + saved.getVisitorId());
        return "redirect:/visitor-portal/request";
    }

    // ==================== EDIT VISITOR ====================

    @GetMapping("/edit/{visitorId}")
    public String editVisitorForm(@PathVariable("visitorId") Long visitorId, Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        Visitor visitor = visitorRepository.findById(visitorId).orElse(null);
        if (visitor == null) return "redirect:/visitor-portal/visit-log";

        model.addAttribute("currentUser", user);
        model.addAttribute("visitor", visitor);
        model.addAttribute("staffList", userRepository.findAll());
        return "visitor-portal/edit-visitor";
    }

    @PostMapping("/edit/{visitorId}")
    public String updateVisitor(@PathVariable("visitorId") Long visitorId,
                                @ModelAttribute Visitor updated,
                                Principal principal,
                                RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        visitorRepository.findById(visitorId).ifPresent(visitor -> {
            visitor.setFullName(updated.getFullName());
            visitor.setNationalIdPassport(updated.getNationalIdPassport());
            visitor.setCompany(updated.getCompany());
            visitor.setPhone(updated.getPhone());
            visitor.setPurposeOfVisit(updated.getPurposeOfVisit());
            visitor.setDepartmentToVisit(updated.getDepartmentToVisit());
            visitor.setVisitDate(updated.getVisitDate());
            visitor.setArrivalTime(updated.getArrivalTime());
            visitor.setExpectedDurationHours(updated.getExpectedDurationHours());
            visitor.setEquipmentCarried(updated.getEquipmentCarried());
            if (updated.getHostEmployee() != null && updated.getHostEmployee().getUserId() != null) {
                visitor.setHostEmployee(updated.getHostEmployee());
            }
            visitorRepository.save(visitor);
        });

        redirectAttributes.addFlashAttribute("success", "Visitor details updated successfully.");
        return "redirect:/visitor-portal/visit-log";
    }

    // ==================== DELETE VISITOR (WITH REASON) ====================

    @PostMapping("/delete/{visitorId}")
    public String deleteVisitor(@PathVariable("visitorId") Long visitorId,
                                @RequestParam String reason,
                                Principal principal,
                                RedirectAttributes redirectAttributes) {
        User officer = getCurrentUser(principal);
        if (officer == null) return "redirect:/login";

        visitorRepository.findById(visitorId).ifPresent(visitor -> {
            // Check if was approved
            boolean wasApproved = visitApprovalRepository.findByVisitor_VisitorId(visitorId).stream()
                .anyMatch(a -> a.getStatus() == VisitApproval.ApprovalStatus.APPROVED);

            // Record deletion log before deleting
            VisitorDeletionLog log = VisitorDeletionLog.builder()
                .visitorName(visitor.getFullName())
                .visitorRef("VR-" + visitorId)
                .visitDate(visitor.getVisitDate())
                .wasApproved(wasApproved)
                .deletedBy(officer)
                .deletionReason(reason)
                .build();
            visitorDeletionLogRepository.save(log);

            // Delete in order: check-in/outs -> approvals -> visitor
            List<VisitorCheckInOut> checks = visitorCheckInOutRepository.findByVisitor_VisitorId(visitorId);
            visitorCheckInOutRepository.deleteAll(checks);
            List<VisitApproval> approvals = visitApprovalRepository.findByVisitor_VisitorId(visitorId);
            visitApprovalRepository.deleteAll(approvals);
            visitorRepository.delete(visitor);
        });

        redirectAttributes.addFlashAttribute("success", "Visitor record deleted successfully.");
        return "redirect:/visitor-portal/visit-log";
    }

    // ==================== MANAGER: APPROVE/REJECT ====================

    @PostMapping("/approve/{approvalId}")
    public String approveVisit(@PathVariable("approvalId") Long approvalId,
                              @RequestParam(defaultValue = "4") Integer durationHours,
                              Principal principal,
                              RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null || (user.getRole() != User.Role.MANAGER && user.getRole() != User.Role.ADMIN)) {
            redirectAttributes.addFlashAttribute("error", "Access denied: Unauthorized operation.");
            return "redirect:/visitor-portal/visit-log";
        }

        try {
            visitorService.approveVisit(approvalId, user.getUserId(), durationHours);
            redirectAttributes.addFlashAttribute("success", "Visit approved by " + user.getFullName());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Approval failed: " + e.getMessage());
        }
        return "redirect:/visitor-portal";
    }

    @PostMapping("/reject/{approvalId}")
    public String rejectVisit(@PathVariable("approvalId") Long approvalId,
                             @RequestParam String reason,
                             Principal principal,
                             RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null || (user.getRole() != User.Role.MANAGER && user.getRole() != User.Role.ADMIN)) {
            redirectAttributes.addFlashAttribute("error", "Access denied: Unauthorized operation.");
            return "redirect:/visitor-portal/visit-log";
        }

        try {
            visitorService.rejectVisit(approvalId, user.getUserId(), reason);
            redirectAttributes.addFlashAttribute("success", "Visit rejected. Reason documented.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Rejection failed: " + e.getMessage());
        }
        return "redirect:/visitor-portal";
    }

    @PostMapping("/request-info/{approvalId}")
    public String requestInfo(@PathVariable("approvalId") Long approvalId,
                              @RequestParam String remarks,
                              Principal principal,
                              RedirectAttributes redirectAttributes) {
        User user = getCurrentUser(principal);
        if (user == null || (user.getRole() != User.Role.MANAGER && user.getRole() != User.Role.ADMIN)) {
            redirectAttributes.addFlashAttribute("error", "Access denied: Unauthorized operation.");
            return "redirect:/visitor-portal/visit-log";
        }

        try {
            visitorService.requestInfo(approvalId, user.getUserId(), remarks);
            redirectAttributes.addFlashAttribute("success", "Information request sent to security.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Request failed: " + e.getMessage());
        }
        return "redirect:/visitor-portal";
    }

    // ==================== VISIT LOG (Approved visitors awaiting check-in) ====================

    @GetMapping("/visit-log")
    public String visitLog(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";
        
        // Admin and Manager are not allowed to see the visit log page
        if (user.getRole() == User.Role.ADMIN || user.getRole() == User.Role.MANAGER) {
            return "redirect:/visitor-portal";
        }

        boolean isAdmin = user.getRole() == User.Role.ADMIN;
        boolean isManager = user.getRole() == User.Role.MANAGER;
        boolean isSecurity = user.getRole() == User.Role.SECURITY;
        boolean isTechnician = user.getRole() == User.Role.TECHNICIAN;

        if (isTechnician) {
            model.addAttribute("awaitingCheckIn", visitorService.getTechnicianAssignments(user.getUserId()));
            model.addAttribute("allApprovals", visitApprovalRepository.findByVisitor_HostEmployee_UserId(user.getUserId()));
        } else {
            model.addAttribute("awaitingCheckIn", visitorService.getWaitingForCheckIn());
            model.addAttribute("allApprovals", visitApprovalRepository.findAll());
            model.addAttribute("allVisitors", visitorRepository.findAll());
        }

        model.addAttribute("isAdmin", isAdmin);
        model.addAttribute("isSecurity", isSecurity);
        model.addAttribute("isManager", isManager);
        model.addAttribute("isTechnician", isTechnician);
        model.addAttribute("currentUser", user);
        model.addAttribute("staffList", userRepository.findAll());
        return "visitor-portal/visit-log";
    }

    @GetMapping("/audit-logs")
    public String auditLogs(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null || user.getRole() != User.Role.ADMIN) return "redirect:/login";

        model.addAttribute("currentUser", user);
        model.addAttribute("logs", visitorService.getLatestActivity(100));
        return "visitor-portal/audit-logs";
    }

    // ==================== NOTIFICATIONS ====================

    @GetMapping("/notifications")
    public String notifications(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        List<Map<String, String>> notifications = new java.util.ArrayList<>();
        
        if (user.getRole() == User.Role.TECHNICIAN) {
            // 1. Assignment Notifications
            List<VisitApproval> assignments = visitorService.getTechnicianAssignments(user.getUserId());
            for (VisitApproval a : assignments) {
                notifications.add(Map.of(
                    "type", "ASSIGNMENT",
                    "title", "Escort Assignment",
                    "content", "You have been assigned to escort Visitor: " + a.getVisitor().getFullName(),
                    "date", a.getCreatedAt().toLocalDate().toString(),
                    "details", "Company: " + a.getVisitor().getCompany() + 
                               " | Purpose: " + a.getVisitor().getPurposeOfVisit() +
                               " | Date: " + a.getVisitor().getVisitDate() +
                               " | Time: " + a.getVisitor().getArrivalTime()
                ));
            }
            // 2. Check-in Notifications
            List<VisitorCheckInOut> active = visitorService.getTechnicianActiveEscorts(user.getUserId());
            for (VisitorCheckInOut v : active) {
                notifications.add(Map.of(
                    "type", "CHECKIN",
                    "title", "Visitor Checked In",
                    "content", "Visitor " + v.getVisitor().getFullName() + " has checked in.",
                    "date", v.getCheckInTime().toLocalDate().toString(),
                    "details", "Location: " + v.getVisitor().getDepartmentToVisit() + 
                               " | Time: " + v.getCheckInTime().toLocalTime().toString().substring(0, 5) +
                               " | Please escort the visitor."
                ));
            }
        } else {
            notifications = List.of(
                Map.of("type", "SYSTEM", "title", "Audit Alert", "content", "Weekly visitor audit log generated.", "date", LocalDate.now().toString(), "details", "View in System Administration"),
                Map.of("type", "SYSTEM", "title", "Security Update", "content", "Access policy v2.4 initialized.", "date", LocalDate.now().toString(), "details", "Changes to visitor duration limits")
            );
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("notifications", notifications);
        return "visitor-portal/notifications";
    }

    // ==================== CHECK-IN ====================

    @PostMapping("/checkin")
    public String checkIn(@RequestParam Long visitorId,
                          @RequestParam(required = false, defaultValue = "") String badge,
                          @RequestParam(required = false) Long escortId,
                          Principal principal,
                          RedirectAttributes redirectAttributes) {
        try {
            // Generate a badge if not provided
            if (badge == null || badge.isBlank()) badge = "BADGE-" + System.currentTimeMillis();
            if (escortId == null) {
                // Default escort to the security officer themselves
                User officer = getCurrentUser(principal);
                escortId = officer != null ? officer.getUserId() : 1L;
            }
            visitorService.checkIn(visitorId, badge, escortId);
            redirectAttributes.addFlashAttribute("success", "Visitor checked in successfully. Active visit started.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Check-in failed: " + e.getMessage());
        }
        return "redirect:/visitor-portal/active";
    }

    // ==================== ACTIVE VISITORS ====================

    @GetMapping("/active")
    public String activeVisitors(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        List<VisitorCheckInOut> active;
        if (user.getRole() == User.Role.TECHNICIAN) {
            active = visitorService.getTechnicianActiveEscorts(user.getUserId());
        } else {
            active = visitorService.getActiveVisitors();
        }

        java.util.Map<Long, String> durationMap = new java.util.HashMap<>();
        for (VisitorCheckInOut v : active) {
            if (v.getCheckInTime() != null) {
                java.time.Duration d = java.time.Duration.between(v.getCheckInTime(), java.time.LocalDateTime.now());
                durationMap.put(v.getCheckId(), String.format("%dh %dm", d.toHours(), d.toMinutesPart()));
            }
        }

        model.addAttribute("isAdmin", user.getRole() == User.Role.ADMIN);
        model.addAttribute("isManager", user.getRole() == User.Role.MANAGER);
        model.addAttribute("isSecurity", user.getRole() == User.Role.SECURITY);
        model.addAttribute("isTechnician", user.getRole() == User.Role.TECHNICIAN);
        model.addAttribute("currentUser", user);
        model.addAttribute("activeVisitors", active);
        model.addAttribute("durationMap", durationMap);
        return "visitor-portal/active";
    }

    // ==================== CHECK-OUT ====================

    @PostMapping("/checkout/{checkId}")
    public String checkOut(@PathVariable("checkId") Long checkId,
                           @RequestParam(defaultValue = "true") boolean equipmentConfirmed,
                           @RequestParam(defaultValue = "true") boolean badgeReturned,
                           RedirectAttributes redirectAttributes,
                           Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null || user.getRole() != User.Role.SECURITY) {
            redirectAttributes.addFlashAttribute("error", "Access denied: Only security officers can perform check-out.");
            return "redirect:/visitor-portal/active";
        }
        try {
            visitorService.checkOut(checkId, equipmentConfirmed, badgeReturned);
            redirectAttributes.addFlashAttribute("success", "Visitor checked out. Visit session closed.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Check-out failed: " + e.getMessage());
        }
        return "redirect:/visitor-portal/active";
    }

    // ==================== ARCHIVE LOG ====================

    @GetMapping("/history")
    public String history(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        List<VisitorCheckInOut> past;
        if (user.getRole() == User.Role.TECHNICIAN) {
            past = visitorService.getTechnicianVisitHistory(user.getUserId());
        } else {
            past = visitorCheckInOutRepository.findAll().stream()
                .filter(v -> Boolean.TRUE.equals(v.getVisitClosed()))
                .sorted((a, b) -> b.getCheckInTime().compareTo(a.getCheckInTime()))
                .collect(Collectors.toList());
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("pastVisits", past);
        return "visitor-portal/history";
    }

    @GetMapping("/history/export-pdf")
    public void exportHistoryPdf(HttpServletResponse response, Principal principal) throws IOException {
        User user = getCurrentUser(principal);
        if (user == null) {
            response.sendRedirect("/login");
            return;
        }

        List<VisitorCheckInOut> past;
        if (user.getRole() == User.Role.TECHNICIAN) {
            past = visitorService.getTechnicianVisitHistory(user.getUserId());
        } else {
            past = visitorCheckInOutRepository.findAll().stream()
                .filter(v -> Boolean.TRUE.equals(v.getVisitClosed()))
                .sorted((a, b) -> b.getCheckInTime().compareTo(a.getCheckInTime()))
                .collect(Collectors.toList());
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=visit_archive_logs.pdf");
        byte[] pdf = buildVisitHistoryPdf(past);
        response.setContentLength(pdf.length);
        response.getOutputStream().write(pdf);
    }

    // ==================== INCIDENTS ====================

    @GetMapping("/report-incident")
    public String reportIncident(@RequestParam(required = false) Long visitorId, Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        Incident incident = new Incident();
        incident.setReportedBy(user);
        if (visitorId != null) {
            incident.setVisitorId(visitorId);
            visitorRepository.findById(visitorId).ifPresent(v -> {
                incident.setTitle("Security Incident: " + v.getFullName());
                incident.setDescription("Incident reported for visitor " + v.getFullName() + " (" + v.getCompany() + ")");
            });
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("incident", incident);
        model.addAttribute("visitorId", visitorId);
        // Also provide active visitors for dropdown linkage
        if (user.getRole() == User.Role.TECHNICIAN) {
            model.addAttribute("activeEscorts", visitorService.getTechnicianActiveEscorts(user.getUserId()));
        } else {
            model.addAttribute("activeEscorts", visitorService.getActiveVisitors());
        }

        return "visitor-portal/report-incident";
    }

    @PostMapping("/save-incident")
    public String saveIncident(@ModelAttribute Incident incident, RedirectAttributes redirectAttributes, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";
        
        incident.setReportedBy(user);
        incident.setStatus(Incident.IncidentStatus.OPEN);
        incidentService.logIncident(incident);

        redirectAttributes.addFlashAttribute("success", "Security incident has been logged and escalated to the Manager.");
        return "redirect:/visitor-portal";
    }

    @PostMapping("/incident")
    public String saveIncidentAlias(@RequestParam(required = false) String type,
                                    @RequestParam(required = false) String description,
                                    RedirectAttributes redirectAttributes,
                                    Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) {
            return "redirect:/login";
        }

        Incident incident = new Incident();
        incident.setReportedBy(user);
        incident.setStatus(Incident.IncidentStatus.OPEN);
        incident.setEquipmentType(Incident.EquipmentType.OTHER);
        incident.setSeverity(Incident.Severity.MEDIUM);
        incident.setTitle((type != null && !type.isBlank()) ? type : "Visitor Portal Incident");
        incident.setDescription(description != null ? description : "");
        incidentService.logIncident(incident);

        redirectAttributes.addFlashAttribute("success", "Security incident has been logged and escalated to the Manager.");
        return "redirect:/visitor-portal/support";
    }

    // ==================== NOTIFICATIONS ====================

    private List<Map<String, String>> getTechnicianDashNotifications(User technician) {
        List<Map<String, String>> notifications = new ArrayList<>();
        
        // 1. Assignment Notifications (Awaiting Check-in)
        List<VisitApproval> assignments = visitorService.getTechnicianAssignments(technician.getUserId());
        for (VisitApproval a : assignments) {
            notifications.add(Map.of(
                "type", "ASSIGNMENT",
                "content", "You are assigned to escort: Visitor " + a.getVisitor().getFullName() + 
                          " from " + a.getVisitor().getCompany() + " on " + a.getVisitor().getVisitDate()
            ));
        }

        // 2. Check-In Notifications (Active sessions started in last 2 hours)
        List<VisitorCheckInOut> active = visitorService.getTechnicianActiveEscorts(technician.getUserId());
        LocalDateTime twoHoursAgo = LocalDateTime.now().minusHours(2);
        for (VisitorCheckInOut check : active) {
            if (check.getCheckInTime() != null && check.getCheckInTime().isAfter(twoHoursAgo)) {
                notifications.add(Map.of(
                    "type", "CHECKIN",
                    "content", "Visitor " + check.getVisitor().getFullName() + " has checked in. Please escort from reception."
                ));
            }
        }
        
        return notifications;
    }

    private byte[] buildVisitHistoryPdf(List<VisitorCheckInOut> visits) throws IOException {
        List<String> lines = new ArrayList<>();
        lines.add("Visit Archive Logs");
        lines.add("");
        lines.add("Visitor | Company | Purpose | Visit Date | In | Out");

        for (VisitorCheckInOut visit : visits) {
            Visitor visitor = visit.getVisitor();
            lines.add(String.join(" | ",
                    abbreviate(visitor != null ? visitor.getFullName() : "", 24),
                    abbreviate(visitor != null ? visitor.getCompany() : "", 18),
                    abbreviate(visitor != null ? visitor.getPurposeOfVisit() : "", 24),
                    visitor != null && visitor.getVisitDate() != null ? visitor.getVisitDate().toString() : "",
                    visit.getCheckInTime() != null ? visit.getCheckInTime().toLocalTime().toString().substring(0, 5) : "",
                    visit.getCheckOutTime() != null ? visit.getCheckOutTime().toLocalTime().toString().substring(0, 5) : ""));
        }

        return buildSinglePagePdf(lines);
    }

    private byte[] buildSinglePagePdf(List<String> lines) throws IOException {
        StringBuilder content = new StringBuilder();
        content.append("BT\n/F1 11 Tf\n");
        int y = 560;
        for (String line : lines) {
            content.append("1 0 0 1 36 ").append(y).append(" Tm\n");
            content.append("(").append(escapePdf(line)).append(") Tj\n");
            y -= 14;
        }
        content.append("ET\n");

        byte[] contentBytes = content.toString().getBytes(StandardCharsets.ISO_8859_1);
        ByteArrayOutputStream pdf = new ByteArrayOutputStream();
        List<Integer> offsets = new ArrayList<>();

        writePdf(pdf, "%PDF-1.4\n");

        offsets.add(pdf.size());
        writePdf(pdf, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");

        offsets.add(pdf.size());
        writePdf(pdf, "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");

        offsets.add(pdf.size());
        writePdf(pdf, "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>\nendobj\n");

        offsets.add(pdf.size());
        writePdf(pdf, "4 0 obj\n<< /Length " + contentBytes.length + " >>\nstream\n");
        pdf.write(contentBytes);
        writePdf(pdf, "endstream\nendobj\n");

        offsets.add(pdf.size());
        writePdf(pdf, "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n");

        int xrefOffset = pdf.size();
        writePdf(pdf, "xref\n0 6\n");
        writePdf(pdf, "0000000000 65535 f \n");
        for (Integer offset : offsets) {
            writePdf(pdf, String.format(Locale.ROOT, "%010d 00000 n \n", offset));
        }
        writePdf(pdf, "trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n" + xrefOffset + "\n%%EOF");

        return pdf.toByteArray();
    }

    private void writePdf(OutputStream outputStream, String value) throws IOException {
        outputStream.write(value.getBytes(StandardCharsets.ISO_8859_1));
    }

    private String escapePdf(String value) {
        return value.replace("\\", "\\\\")
                .replace("(", "\\(")
                .replace(")", "\\)");
    }

    private String abbreviate(String value, int maxLength) {
        if (value == null) {
            return "";
        }
        String normalized = value.replaceAll("\\s+", " ").trim();
        if (normalized.length() <= maxLength) {
            return normalized;
        }
        return normalized.substring(0, Math.max(0, maxLength - 3)) + "...";
    }

    @GetMapping("/support")
    public String support(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";
        model.addAttribute("currentUser", user);
        return "visitor-portal/support";
    }
}
