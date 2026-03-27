package com.spcms.repositories;

import com.spcms.models.CoolingAlarmLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CoolingAlarmLogRepository extends JpaRepository<CoolingAlarmLog, Long> {
    List<CoolingAlarmLog> findByCoolingUnit_CoolingIdOrderByAlarmTimeDesc(Long coolingId);
    List<CoolingAlarmLog> findBySeverity(CoolingAlarmLog.Severity severity);
    List<CoolingAlarmLog> findByAlarmTimeBetween(LocalDateTime start, LocalDateTime end);
    List<CoolingAlarmLog> findByResolutionTimeIsNull();
}
