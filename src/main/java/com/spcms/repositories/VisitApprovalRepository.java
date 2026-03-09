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
}
