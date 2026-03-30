package com.spcms.repositories;

import com.spcms.models.AlertAcknowledgment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlertAcknowledgmentRepository extends JpaRepository<AlertAcknowledgment, Long> {

    boolean existsByAlertAlertIdAndUserUserId(Long alertId, Long userId);

    Optional<AlertAcknowledgment> findByAlertAlertIdAndUserUserId(Long alertId, Long userId);

    List<AlertAcknowledgment> findByUserUserId(Long userId);

    List<AlertAcknowledgment> findByUserUserIdAndAlertAlertIdIn(Long userId, List<Long> alertIds);
}
