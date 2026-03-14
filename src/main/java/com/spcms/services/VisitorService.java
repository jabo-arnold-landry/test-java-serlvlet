package com.spcms.services;

import com.spcms.models.Visitor;
import com.spcms.models.VisitApproval;
import com.spcms.models.VisitorCheckInOut;
import com.spcms.repositories.VisitorRepository;
import com.spcms.repositories.VisitApprovalRepository;
import com.spcms.repositories.VisitorCheckInOutRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class VisitorService {

    @Autowired
    private VisitorRepository visitorRepository;

    @Autowired
    private VisitApprovalRepository visitApprovalRepository;

    @Autowired
    private VisitorCheckInOutRepository visitorCheckInOutRepository;

    @Autowired
    private com.spcms.repositories.IncidentRepository incidentRepository;

    // ==================== Visitor Registration ====================

    public Visitor registerVisitor(Visitor visitor) {
        // Generate a unique pass number
        visitor.setPassNumber("VP-" + System.currentTimeMillis());
        return visitorRepository.save(visitor);
    }

    public Optional<Visitor> getVisitorById(Long id) {
        return visitorRepository.findById(id);
    }

    public List<Visitor> getAllVisitors() {
        return visitorRepository.findAll();
    }

    public List<Visitor> getVisitorsByDate(LocalDate date) {
        return visitorRepository.findByVisitDate(date);
    }

    public List<Visitor> getVisitorsByDateRange(LocalDate start, LocalDate end) {
        return visitorRepository.findByVisitDateBetween(start, end);
    }

    // ==================== Approval Workflow ====================

    public VisitApproval submitForApproval(Long visitorId) {
        Visitor visitor = visitorRepository.findById(visitorId)
                .orElseThrow(() -> new RuntimeException("Visitor not found: " + visitorId));
        VisitApproval approval = VisitApproval.builder()
                .visitor(visitor)
                .status(VisitApproval.ApprovalStatus.PENDING)
                .build();
        return visitApprovalRepository.save(approval);
    }

    public VisitApproval approveVisit(Long approvalId, Long managerId, Integer durationHours) {
        VisitApproval approval = visitApprovalRepository.findById(approvalId)
                .orElseThrow(() -> new RuntimeException("Approval not found: " + approvalId));
        var manager = new com.spcms.models.User();
        manager.setUserId(managerId);
        approval.setApprovedBy(manager);
        approval.setStatus(VisitApproval.ApprovalStatus.APPROVED);
        approval.setDecisionTime(LocalDateTime.now());
        approval.setApprovedDurationHours(durationHours);
        approval.setNotificationSent(true); // TODO: send actual notification
        return visitApprovalRepository.save(approval);
    }

    public VisitApproval rejectVisit(Long approvalId, Long managerId, String reason) {
        VisitApproval approval = visitApprovalRepository.findById(approvalId)
                .orElseThrow(() -> new RuntimeException("Approval not found: " + approvalId));
        var manager = new com.spcms.models.User();
        manager.setUserId(managerId);
        approval.setApprovedBy(manager);
        approval.setStatus(VisitApproval.ApprovalStatus.REJECTED);
        approval.setDecisionTime(LocalDateTime.now());
        approval.setRemarks(reason);
        return visitApprovalRepository.save(approval);
    }

    public List<VisitApproval> getPendingApprovals() {
        return visitApprovalRepository.findByStatus(VisitApproval.ApprovalStatus.PENDING);
    }

    public List<VisitApproval> getWaitingForCheckIn() {
        return visitApprovalRepository.findApprovedWaitingForCheckIn(VisitApproval.ApprovalStatus.APPROVED);
    }

    public List<VisitApproval> getHistoricalApprovals() {
        return visitApprovalRepository.findAll().stream()
            .filter(a -> a.getStatus() != VisitApproval.ApprovalStatus.PENDING)
            .sorted(java.util.Comparator.comparing(VisitApproval::getDecisionTime, java.util.Comparator.nullsLast(java.util.Comparator.reverseOrder())))
            .toList();
    }

    public List<VisitApproval> getApprovedVisitsToday() {
        return getWaitingForCheckIn().stream()
            .filter(a -> a.getVisitor().getVisitDate().equals(LocalDate.now()))
            .toList();
    }

    // ==================== Check-In / Check-Out ====================

    public VisitorCheckInOut checkIn(Long visitorId, String temporaryBadge, Long escortId) {
        Visitor visitor = visitorRepository.findById(visitorId)
                .orElseThrow(() -> new RuntimeException("Visitor not found: " + visitorId));
        var escort = new com.spcms.models.User();
        escort.setUserId(escortId);

        VisitorCheckInOut checkInOut = VisitorCheckInOut.builder()
                .visitor(visitor)
                .checkInTime(LocalDateTime.now())
                .temporaryBadge(temporaryBadge)
                .escort(escort)
                .equipmentConfirmedOut(false)
                .visitClosed(false)
                .build();
        return visitorCheckInOutRepository.save(checkInOut);
    }

    public VisitorCheckInOut checkOut(Long checkId, boolean equipmentConfirmed, boolean badgeReturned) {
        VisitorCheckInOut checkInOut = visitorCheckInOutRepository.findById(checkId)
                .orElseThrow(() -> new RuntimeException("Check-in record not found: " + checkId));
        checkInOut.setCheckOutTime(LocalDateTime.now());
        checkInOut.setEquipmentConfirmedOut(equipmentConfirmed);
        checkInOut.setBadgeReturned(badgeReturned);
        checkInOut.setVisitClosed(true);
        return visitorCheckInOutRepository.save(checkInOut);
    }

    public long countCompletedVisitsToday() {
        return visitorCheckInOutRepository.countCompletedToday();
    }

    public List<VisitorCheckInOut> getActiveVisitors() {
        return visitorCheckInOutRepository.findActiveVisitors();
    }

    public List<VisitorCheckInOut> getOverstayedVisitors() {
        List<VisitorCheckInOut> active = getActiveVisitors();
        List<VisitorCheckInOut> overstayed = new java.util.ArrayList<>();
        for (VisitorCheckInOut visit : active) {
            List<VisitApproval> approvals = visitApprovalRepository.findByVisitor_VisitorId(visit.getVisitor().getVisitorId());
            VisitApproval latestApproval = approvals.stream()
                .filter(a -> a.getStatus() == VisitApproval.ApprovalStatus.APPROVED && a.getDecisionTime() != null)
                .max(java.util.Comparator.comparing(VisitApproval::getDecisionTime))
                .orElse(null);
            
            if (latestApproval != null && latestApproval.getApprovedDurationHours() != null && visit.getCheckInTime() != null) {
                LocalDateTime expectedOut = visit.getCheckInTime().plusHours(latestApproval.getApprovedDurationHours());
                if (LocalDateTime.now().isAfter(expectedOut)) {
                    overstayed.add(visit);
                }
            }
        }
        return overstayed;
    }

    public List<VisitorCheckInOut> getVisitHistory(LocalDate start, LocalDate end) {
        return visitorCheckInOutRepository.findVisitHistory(start, end);
    }

    public List<Object[]> getHighFrequencyVisitors() {
        return visitorCheckInOutRepository.findHighFrequencyVisitors();
    }

    public com.spcms.models.Incident saveIncident(com.spcms.models.Incident incident) {
        return incidentRepository.save(incident);
    }

    // ==================== Technician Specific ====================

    public List<VisitApproval> getTechnicianAssignments(Long userId) {
        return visitApprovalRepository.findByVisitor_HostEmployee_UserIdAndStatus(userId, VisitApproval.ApprovalStatus.APPROVED);
    }

    public List<VisitorCheckInOut> getTechnicianActiveEscorts(Long userId) {
        return visitorCheckInOutRepository.findByEscort_UserIdAndVisitClosedOrderByCheckInTimeDesc(userId, false);
    }

    public List<VisitorCheckInOut> getTechnicianVisitHistory(Long userId) {
        return visitorCheckInOutRepository.findByEscort_UserIdAndVisitClosedOrderByCheckInTimeDesc(userId, true);
    }

    public List<com.spcms.models.Incident> getTechnicianIncidents(Long userId) {
        return incidentRepository.findByReportedBy_UserIdOrderByCreatedAtDesc(userId);
    }
}
