package com.spcms.repositories;

import com.spcms.models.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {

    List<Alert> findByIsSentFalse();

    List<Alert> findByIsAcknowledgedFalse();

    long countByIsAcknowledgedFalse();

    Optional<Alert> findFirstByAlertIdGreaterThanOrderByAlertIdDesc(Long afterId);

    Optional<Alert> findFirstByOrderByAlertIdDesc();
}
