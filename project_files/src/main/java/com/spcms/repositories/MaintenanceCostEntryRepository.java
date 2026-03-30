package com.spcms.repositories;

import com.spcms.models.MaintenanceCostEntry;
import com.spcms.models.MaintenanceCostEntry.EquipmentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MaintenanceCostEntryRepository extends JpaRepository<MaintenanceCostEntry, Long> {

    List<MaintenanceCostEntry> findByEquipmentType(EquipmentType equipmentType);

    List<MaintenanceCostEntry> findByMaintenanceIdAndEquipmentType(Long maintenanceId, EquipmentType equipmentType);

    List<MaintenanceCostEntry> findByRecordedAtBetweenOrderByRecordedAtDesc(LocalDateTime start, LocalDateTime end);

    List<MaintenanceCostEntry> findByEquipmentTypeAndRecordedAtBetweenOrderByRecordedAtDesc(
            EquipmentType equipmentType, LocalDateTime start, LocalDateTime end);

    List<MaintenanceCostEntry> findAllByOrderByRecordedAtDesc();

    @Query("SELECT COALESCE(SUM(c.costAmount), 0) FROM MaintenanceCostEntry c")
    BigDecimal sumAllCosts();

    @Query("SELECT COALESCE(SUM(c.costAmount), 0) FROM MaintenanceCostEntry c WHERE c.equipmentType = :type")
    BigDecimal sumCostsByType(@Param("type") EquipmentType type);

    @Query("SELECT COALESCE(SUM(c.costAmount), 0) FROM MaintenanceCostEntry c WHERE c.recordedAt BETWEEN :start AND :end")
    BigDecimal sumCostsByDateRange(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT COALESCE(SUM(c.costAmount), 0) FROM MaintenanceCostEntry c WHERE c.equipmentType = :type AND c.recordedAt BETWEEN :start AND :end")
    BigDecimal sumCostsByTypeAndDateRange(@Param("type") EquipmentType type,
                                          @Param("start") LocalDateTime start,
                                          @Param("end") LocalDateTime end);
}
