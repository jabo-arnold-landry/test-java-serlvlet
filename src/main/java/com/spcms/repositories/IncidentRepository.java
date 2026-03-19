package com.spcms.repositories;

import com.spcms.models.Incident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface IncidentRepository extends JpaRepository<Incident, Long> {
    List<Incident> findByStatusOrderByCreatedAtDesc(Incident.IncidentStatus status);
    List<Incident> findBySeverityOrderByCreatedAtDesc(Incident.Severity severity);
    List<Incident> findByEquipmentTypeAndEquipmentId(Incident.EquipmentType type, Long equipmentId);
    List<Incident> findByAssignedTo_UserId(Long userId);
    List<Incident> findByReportedBy_UserIdOrderByCreatedAtDesc(Long userId);
    List<Incident> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);

    @Query("SELECT SUM(i.downtimeMinutes) FROM Incident i WHERE i.createdAt BETWEEN :start AND :end")
    Integer sumDowntimeMinutes(LocalDateTime start, LocalDateTime end);

    @Query("SELECT COUNT(i) FROM Incident i WHERE i.severity = 'CRITICAL' AND i.createdAt BETWEEN :start AND :end")
    Long countCriticalIncidents(LocalDateTime start, LocalDateTime end);
}
