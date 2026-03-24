package com.spcms.repositories;

import com.spcms.models.MonitoringLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MonitoringLogRepository extends JpaRepository<MonitoringLog, Long> {
    long countByEquipmentTypeAndEquipmentId(MonitoringLog.EquipmentType type, Long equipmentId);

    List<MonitoringLog> findByEquipmentTypeAndEquipmentIdOrderByReadingTimeDesc(
            MonitoringLog.EquipmentType type, Long equipmentId);

    List<MonitoringLog> findByReadingTimeBetweenOrderByReadingTimeDesc(
            LocalDateTime start, LocalDateTime end);

    @Query("SELECT m FROM MonitoringLog m WHERE m.equipmentType = :type AND m.readingTime BETWEEN :start AND :end")
    List<MonitoringLog> findByTypeAndDateRange(MonitoringLog.EquipmentType type,
                                                LocalDateTime start, LocalDateTime end);
}
