package com.spcms.repositories;

import com.spcms.models.UpsMaintenance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface UpsMaintenanceRepository extends JpaRepository<UpsMaintenance, Long> {
    List<UpsMaintenance> findByUps_UpsIdOrderByMaintenanceDateDesc(Long upsId);
    List<UpsMaintenance> findByMaintenanceType(UpsMaintenance.MaintenanceType type);
    List<UpsMaintenance> findByMaintenanceDateBetween(LocalDate start, LocalDate end);

    @Query("SELECT m FROM UpsMaintenance m WHERE m.nextDueDate <= :date")
    List<UpsMaintenance> findOverdue(@Param("date") LocalDate date);
}