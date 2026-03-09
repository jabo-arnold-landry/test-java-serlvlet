package com.spcms.repositories;

import com.spcms.models.UpsBattery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface UpsBatteryRepository extends JpaRepository<UpsBattery, Long> {
    List<UpsBattery> findByUps_UpsId(Long upsId);
    List<UpsBattery> findByBatteryHealthStatus(UpsBattery.BatteryHealthStatus status);

    @Query("SELECT b FROM UpsBattery b WHERE b.replacementDueDate <= :date")
    List<UpsBattery> findDueForReplacement(LocalDate date);

    @Query("SELECT b FROM UpsBattery b WHERE b.batteryHealthStatus IN ('POOR','CRITICAL','REPLACE')")
    List<UpsBattery> findUnhealthyBatteries();
}
