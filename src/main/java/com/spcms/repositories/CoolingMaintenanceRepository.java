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

    @Query("SELECT m FROM CoolingMaintenance m WHERE m.nextMaintenanceDate <= :date")
    List<CoolingMaintenance> findOverdue(LocalDate date);
}
