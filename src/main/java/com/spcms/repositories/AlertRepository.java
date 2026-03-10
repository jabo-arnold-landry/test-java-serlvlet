package com.spcms.repositories;

import com.spcms.models.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByIsSentFalse();
    List<Alert> findByIsAcknowledgedFalse();
    long countByIsAcknowledgedFalse();
    List<Alert> findByAlertType(Alert.AlertType alertType);
    List<Alert> findByEquipmentTypeAndEquipmentId(Alert.EquipmentCategory type, Long equipmentId);
    java.util.Optional<Alert> findFirstByOrderByAlertIdDesc();
    java.util.Optional<Alert> findFirstByAlertIdGreaterThanOrderByAlertIdDesc(Long alertId);
}
