package com.spcms.services;

import com.spcms.models.Incident;
import com.spcms.repositories.IncidentRepository;
import com.spcms.repositories.UserRepository;
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

    @Autowired
    private UserRepository userRepository;
    // ==================== CRUD ====================

    public Incident logIncident(Incident incident) {
        return incidentRepository.save(incident);
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

    public List<Incident> getResolvedIncidents() {
        return incidentRepository.findByStatusInOrderByUpdatedAtDesc(
                List.of(Incident.IncidentStatus.RESOLVED));
    }

    public void deleteIncident(Long id) {
        incidentRepository.deleteById(id);
    }

    // ==================== Status Management ====================

    public Incident assignIncident(Long incidentId, String assigneeUsername) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        if (incident.getStatus() == Incident.IncidentStatus.RESOLVED) {
            throw new IllegalStateException("Incident is already solved and cannot be assigned.");
        }
        if (incident.getAssignedTo() != null) {
            throw new IllegalStateException("Incident is already assigned and cannot be reassigned.");
        }
        var user = userRepository.findByUsername(assigneeUsername)
                .orElseThrow(() -> new RuntimeException("User not found: " + assigneeUsername));
        incident.setAssignedTo(user);
        incident.setStatus(Incident.IncidentStatus.IN_PROGRESS);
        return incidentRepository.save(incident);
    }

    public Incident resolveIncident(Long incidentId,
                                    String rootCause,
                                    String actionTaken,
                                    String resolvedByUsername,
                                    LocalDateTime resolvedAt) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        if (incident.getAssignedTo() == null
                || resolvedByUsername == null
                || !incident.getAssignedTo().getUsername().equals(resolvedByUsername)) {
            throw new IllegalStateException("Only the assigned user can resolve this incident.");
        }
        if (incident.getStatus() == Incident.IncidentStatus.RESOLVED) {
            throw new IllegalStateException("Incident is already solved.");
        }
        incident.setStatus(Incident.IncidentStatus.RESOLVED);
        incident.setRootCause(rootCause);
        incident.setActionTaken(actionTaken);
        LocalDateTime resolvedTime = resolvedAt != null ? resolvedAt : LocalDateTime.now();
        incident.setDowntimeEnd(resolvedTime);
        incident.setResolvedAt(resolvedTime);

        var user = userRepository.findByUsername(resolvedByUsername)
                .orElseThrow(() -> new RuntimeException("User not found: " + resolvedByUsername));
        incident.setResolvedBy(user);

        // Calculate downtime
        if (incident.getDowntimeStart() != null) {
            long minutes = ChronoUnit.MINUTES.between(incident.getDowntimeStart(), incident.getDowntimeEnd());
            incident.setDowntimeMinutes((int) minutes);
        }

        return incidentRepository.save(incident);
    }

    public Incident closeIncident(Long incidentId) {
        Incident incident = incidentRepository.findById(incidentId)
                .orElseThrow(() -> new RuntimeException("Incident not found: " + incidentId));
        incident.setStatus(Incident.IncidentStatus.RESOLVED);
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
}
