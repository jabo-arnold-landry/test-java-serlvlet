package com.spcms.repositories;

import com.spcms.models.DecisionRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DecisionRequestRepository extends JpaRepository<DecisionRequest, Long> {
    List<DecisionRequest> findByStatus(DecisionRequest.Status status);
    List<DecisionRequest> findByRequestedBy_UserId(Long userId);
    List<DecisionRequest> findByRequestType(DecisionRequest.RequestType requestType);
}
