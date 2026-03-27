package com.spcms.repositories;

import com.spcms.models.CoolingMaintenance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface CoolingMaintenanceRepository extends JpaRepository<CoolingMaintenance, Long> {
    List<CoolingMaintenance> findByCoolingUnit_CoolingIdOrderByMaintenanceDateDesc(Long coolingId);
    List<CoolingMaintenance> findByMaintenanceDateBetween(LocalDate start, LocalDate end);
    List<CoolingMaintenance> findAllByOrderByMaintenanceDateDesc();

    @Query("SELECT m FROM CoolingMaintenance m WHERE m.nextMaintenanceDate <= :date")
    List<CoolingMaintenance> findOverdue(@org.springframework.data.repository.query.Param("date") LocalDate date);

    @Query("SELECT m FROM CoolingMaintenance m WHERE m.nextMaintenanceDate > :today AND m.nextMaintenanceDate <= :window")
    List<CoolingMaintenance> findUpcoming(@org.springframework.data.repository.query.Param("today") LocalDate today, @org.springframework.data.repository.query.Param("window") LocalDate window);

    long countByMaintenanceType(CoolingMaintenance.MaintenanceType type);
}
