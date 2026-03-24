package com.spcms.services;

import com.spcms.models.Incident;
import com.spcms.repositories.IncidentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class IncidentService {

    @Autowired
    private IncidentRepository incidentRepository;

    // ==================== CRUD ====================

    public Incident logIncident(Incident incident) {
        return incidentRepository.save(incident);
    }

    public void deleteIncident(Long id) {
        incidentRepository.deleteById(id);
    }

    public Optional<Incident> getIncidentById(Long id) {
        return incidentRepository.findById(id);
    }

    public List<Incident> getAllIncidents() {
        return incidentRepository.findAll();
    }

    public List<Incident> getIncidentsByStatus(Incident.IncidentStatus status) {
        return incidentRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    public List<Incident> getIncidentsBySeverity(Incident.Severity severity) {
        return incidentRepository.findBySeverityOrderByCreatedAtDesc(severity);
    }

    public List<Incident> getIncidentsForEquipment(Incident.EquipmentType type, Long equipmentId) {
        return incidentRepository.findByEquipmentTypeAndEquipmentId(type, equipmentId);
    }

    public List<Incident> getIncidentsByDateRange(LocalDateTime start, LocalDateTime end) {
        return incidentRepository.findByCreatedAtBetween(start, end);
    }

    // ==================== Status Management ====================

    public Incident assignIncident(Long incidentId, Long assigneeId) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        var user = new com.spcms.models.User();
        user.setUserId(assigneeId);
        incident.setAssignedTo(user);
        incident.setStatus(Incident.IncidentStatus.IN_PROGRESS);
        return incidentRepository.save(incident);
    }

    public Incident resolveIncident(Long incidentId, String rootCause, String actionTaken, Long resolverId, LocalDateTime downtimeStart, Incident.IncidentStatus status) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        
        if (status != null) {
            incident.setStatus(status);
        } else {
            incident.setStatus(Incident.IncidentStatus.RESOLVED);
        }

        incident.setRootCause(rootCause);
        incident.setActionTaken(actionTaken);
        
        if (downtimeStart != null) {
            incident.setDowntimeStart(downtimeStart);
        }

        if (incident.getStatus() == Incident.IncidentStatus.RESOLVED || incident.getStatus() == Incident.IncidentStatus.CLOSED) {
            if (incident.getDowntimeEnd() == null) {
                incident.setDowntimeEnd(LocalDateTime.now());
            }
        }

        if (resolverId != null) {
            var resolver = new com.spcms.models.User();
            resolver.setUserId(resolverId);
            incident.setResolvedBy(resolver);
        }

        // Calculate downtime
        if (incident.getDowntimeStart() != null && incident.getDowntimeEnd() != null) {
            long minutes = ChronoUnit.MINUTES.between(incident.getDowntimeStart(), incident.getDowntimeEnd());
            incident.setDowntimeMinutes((int) Math.max(0, minutes));
        }

        return incidentRepository.save(incident);
    }

    public Incident closeIncident(Long incidentId) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        incident.setStatus(Incident.IncidentStatus.CLOSED);
        return incidentRepository.save(incident);
    }

    // ==================== Analytics ====================

    public Integer getTotalDowntimeMinutes(LocalDateTime start, LocalDateTime end) {
        Integer total = incidentRepository.sumDowntimeMinutes(start, end);
        return total != null ? total : 0;
    }

    public Long getCriticalIncidentCount(LocalDateTime start, LocalDateTime end) {
        return incidentRepository.countCriticalIncidents(start, end);
    }

    // ==================== Incident Report ====================

    public List<Incident> getIncidentsForDate(LocalDateTime start, LocalDateTime end) {
        return incidentRepository.findByCreatedAtBetween(start, end);
    }

    public List<Incident> getResolvedIncidentsForDate(LocalDateTime start, LocalDateTime end) {
        return incidentRepository.findByStatusAndCreatedAtBetween(
                Incident.IncidentStatus.RESOLVED, start, end);
    }

    public List<Object[]> getIncidentCountByEquipmentType(LocalDateTime start, LocalDateTime end) {
        return incidentRepository.countByEquipmentType(start, end);
    }
}
