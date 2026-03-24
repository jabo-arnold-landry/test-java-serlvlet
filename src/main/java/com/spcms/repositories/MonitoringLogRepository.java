package com.spcms.repositories;

import com.spcms.models.MonitoringLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.repository.query.Param;

@Repository
public interface MonitoringLogRepository extends JpaRepository<MonitoringLog, Long> {
    long countByEquipmentTypeAndEquipmentId(MonitoringLog.EquipmentType type, Long equipmentId);

    List<MonitoringLog> findByEquipmentTypeAndEquipmentIdOrderByReadingTimeDesc(
            MonitoringLog.EquipmentType type, Long equipmentId);

    // Replace both broken methods with these:

    // Method 1 - derived query:
    List<MonitoringLog> findByCreatedAtBetweenOrderByCreatedAtDesc(LocalDateTime start, LocalDateTime end);

    // Method 2 - @Query annotation:
    @Query("SELECT m FROM MonitoringLog m WHERE m.equipmentType = :type AND m.createdAt BETWEEN :start AND :end")
    List<MonitoringLog> findByTypeAndDateRange(
            @Param("type") MonitoringLog.EquipmentType type,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );
}
