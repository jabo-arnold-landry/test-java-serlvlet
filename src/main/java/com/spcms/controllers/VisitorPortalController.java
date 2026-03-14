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

import java.security.Principal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
        
        long pending;
        long awaiting;
        long activeCount;
        long completed;
        List<Map<String, Object>> recent;

        if (isTechnician) {
            // Technician sees only their own stats
            pending     = 0; // Technicians don't "approve"
            
            List<VisitApproval> myAssignments = visitorService.getTechnicianAssignments(user.getUserId());
            List<VisitorCheckInOut> myActive = visitorService.getTechnicianActiveEscorts(user.getUserId());
            List<VisitorCheckInOut> myHistory = visitorService.getTechnicianVisitHistory(user.getUserId());

            awaiting    = myAssignments.size();
            activeCount = myActive.size();
            completed   = myHistory.stream()
                            .filter(v -> v.getCheckOutTime() != null && v.getCheckOutTime().toLocalDate().equals(LocalDate.now()))
                            .count();
            
            // Comprehensive recent assignments for the table (Approved & Active)
            recent = new ArrayList<>();
            // Add Active first
            myActive.stream().limit(3).forEach(v -> {
                recent.add(Map.of(
                    "visitDate",      v.getVisitor().getVisitDate().toString(),
                    "visitorName",    v.getVisitor().getFullName(),
                    "company",        v.getVisitor().getCompany(),
                    "purposeOfVisit", v.getVisitor().getPurposeOfVisit(),
                    "status",         "ACTIVE"
                ));
            });
            // Add Approved
            myAssignments.stream().limit(5 - recent.size()).forEach(a -> {
                recent.add(Map.of(
                    "visitDate",      a.getVisitor().getVisitDate().toString(),
                    "visitorName",    a.getVisitor().getFullName(),
                    "company",        a.getVisitor().getCompany(),
                    "purposeOfVisit", a.getVisitor().getPurposeOfVisit(),
                    "status",         "APPROVED"
                ));
            });
        } else {
            // Security/Manager sees system-wide stats
            pending     = visitorService.getPendingApprovals().size();
            awaiting    = visitorService.getWaitingForCheckIn().size();
            activeCount = visitorService.getActiveVisitors().size();
            completed   = visitorService.countCompletedVisitsToday();

            recent = visitApprovalRepository.findAll().stream()
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .limit(5)
                .map(a -> {
                    String status = a.getStatus().name();
                    List<VisitorCheckInOut> checks = visitorCheckInOutRepository.findByVisitor_VisitorId(a.getVisitor().getVisitorId());
                    boolean isClosed = checks.stream().anyMatch(v1 -> Boolean.TRUE.equals(v1.getVisitClosed()));
                    boolean isActive = checks.stream().anyMatch(v1 -> !Boolean.TRUE.equals(v1.getVisitClosed()));
                    if (isClosed) status = "COMPLETED";
                    else if (isActive) status = "ACTIVE";

                    return Map.<String, Object>of(
                        "visitDate",      a.getVisitor().getVisitDate().toString(),
                        "visitorName",    a.getVisitor().getFullName(),
                        "company",        a.getVisitor().getCompany(),
                        "purposeOfVisit", a.getVisitor().getPurposeOfVisit(),
                        "status",         status
                    );
                })
                .collect(Collectors.toList());
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("pendingCount", pending);
        model.addAttribute("awaitingCount", awaiting); 
        model.addAttribute("activeCount", activeCount);
        model.addAttribute("completedCount", completed);
        model.addAttribute("recentVisits", recent);
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
    public String editVisitorForm(@PathVariable Long visitorId, Model model, Principal principal) {
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
    public String updateVisitor(@PathVariable Long visitorId,
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
    public String deleteVisitor(@PathVariable Long visitorId,
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

        redirectAttributes.addFlashAttribute("success", "Visitor record deleted. Manager has been notified.");
        return "redirect:/visitor-portal/visit-log";
    }

    // ==================== VISIT LOG (Approved visitors awaiting check-in) ====================

    @GetMapping("/visit-log")
    public String visitLog(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";

        if (user.getRole() == User.Role.TECHNICIAN) {
            model.addAttribute("awaitingCheckIn", visitorService.getTechnicianAssignments(user.getUserId()));
        } else {
            model.addAttribute("awaitingCheckIn", visitorService.getWaitingForCheckIn());
            model.addAttribute("allApprovals", visitApprovalRepository.findAll());
            model.addAttribute("allVisitors", visitorRepository.findAll());
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("staffList", userRepository.findAll());
        return "visitor-portal/visit-log";
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

        model.addAttribute("currentUser", user);
        model.addAttribute("activeVisitors", active);
        model.addAttribute("durationMap", durationMap);
        return "visitor-portal/active";
    }

    // ==================== CHECK-OUT ====================

    @PostMapping("/checkout/{checkId}")
    public String checkOut(@PathVariable Long checkId,
                           @RequestParam(defaultValue = "true") boolean equipmentConfirmed,
                           @RequestParam(defaultValue = "true") boolean badgeReturned,
                           RedirectAttributes redirectAttributes) {
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

    // ==================== NOTIFICATIONS ====================
    @GetMapping("/support")
    public String support(Model model, Principal principal) {
        User user = getCurrentUser(principal);
        if (user == null) return "redirect:/login";
        model.addAttribute("currentUser", user);
        return "visitor-portal/support";
    }
}
