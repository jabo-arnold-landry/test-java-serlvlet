package com.spcms.repositories;

import com.spcms.models.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByIsSentFalse();
    List<Alert> findByIsAcknowledgedFalse();
    List<Alert> findByIsAcknowledgedTrue();
    long countByIsAcknowledgedFalse();
    List<Alert> findByAlertType(Alert.AlertType alertType);
    List<Alert> findByEquipmentTypeAndEquipmentId(Alert.EquipmentCategory type, Long equipmentId);
    java.util.Optional<Alert> findFirstByOrderByAlertIdDesc();
    java.util.Optional<Alert> findFirstByAlertIdGreaterThanOrderByAlertIdDesc(Long alertId);

    @Query("""
            select a from Alert a
            where not exists (
                select 1 from AlertAcknowledgment aa
                where aa.alert = a and aa.user.userId = :userId
            )
            """)
    List<Alert> findUnacknowledgedByUserId(@Param("userId") Long userId);

    @Query("""
            select count(a) from Alert a
            where not exists (
                select 1 from AlertAcknowledgment aa
                where aa.alert = a and aa.user.userId = :userId
            )
            """)
    long countUnacknowledgedByUserId(@Param("userId") Long userId);
}
