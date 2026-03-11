package com.spcms.repositories;

import com.spcms.models.VisitApproval;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VisitApprovalRepository extends JpaRepository<VisitApproval, Long> {
    List<VisitApproval> findByStatus(VisitApproval.ApprovalStatus status);
    List<VisitApproval> findByVisitor_VisitorId(Long visitorId);
    List<VisitApproval> findByApprovedBy_UserId(Long managerId);

    @org.springframework.data.jpa.repository.Query("SELECT a FROM VisitApproval a WHERE a.status = 'APPROVED' AND NOT EXISTS (SELECT c FROM VisitorCheckInOut c WHERE c.visitor = a.visitor)")
    List<VisitApproval> findApprovedWaitingForCheckIn();
}
