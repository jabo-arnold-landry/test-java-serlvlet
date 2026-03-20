package com.spcms.repositories;

import com.spcms.models.DecisionRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DecisionRequestRepository extends JpaRepository<DecisionRequest, Long> {
}
