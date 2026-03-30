package com.spcms.services;

import com.spcms.models.MaintenanceCostEntry;
import com.spcms.models.MaintenanceCostEntry.EquipmentType;
import com.spcms.repositories.MaintenanceCostEntryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class MaintenanceCostEntryService {

    @Autowired
    private MaintenanceCostEntryRepository repository;

    @Autowired
    private ActivityLogService activityLogService;

    // ==================== CRUD ====================

    public MaintenanceCostEntry save(MaintenanceCostEntry entry, HttpServletRequest request) {
        boolean isNew = entry.getCostId() == null;
        if (entry.getCostAmount() == null || entry.getCostAmount().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Cost amount must be positive");
        }
        MaintenanceCostEntry saved = repository.save(entry);

        String action = isNew ? "COST_ADDED" : "COST_EDITED";
        activityLogService.log(action, entry.getEquipmentType().name() + "_MAINTENANCE",
                entry.getMaintenanceId(),
                action + ": RWF " + saved.getCostAmount() + " — " + saved.getCostDescription(),
                request);
        return saved;
    }

    public void delete(Long costId, HttpServletRequest request) {
        repository.findById(costId).ifPresent(entry -> {
            activityLogService.log("COST_DELETED", entry.getEquipmentType().name() + "_MAINTENANCE",
                    entry.getMaintenanceId(),
                    "Deleted cost: RWF " + entry.getCostAmount() + " — " + entry.getCostDescription(),
                    request);
            repository.deleteById(costId);
        });
    }

    public Optional<MaintenanceCostEntry> findById(Long id) {
        return repository.findById(id);
    }

    public List<MaintenanceCostEntry> findAll() {
        return repository.findAllByOrderByRecordedAtDesc();
    }

    public List<MaintenanceCostEntry> findByMaintenanceRecord(Long maintenanceId, EquipmentType type) {
        return repository.findByMaintenanceIdAndEquipmentType(maintenanceId, type);
    }

    // ==================== Filtered Queries ====================

    public List<MaintenanceCostEntry> findFiltered(EquipmentType type, LocalDateTime start, LocalDateTime end) {
        if (type != null) {
            return repository.findByEquipmentTypeAndRecordedAtBetweenOrderByRecordedAtDesc(type, start, end);
        }
        return repository.findByRecordedAtBetweenOrderByRecordedAtDesc(start, end);
    }

    // ==================== Aggregations ====================

    public BigDecimal getTotalCost() {
        return repository.sumAllCosts();
    }

    public BigDecimal getCostByType(EquipmentType type) {
        return repository.sumCostsByType(type);
    }

    public BigDecimal getCostByDateRange(LocalDateTime start, LocalDateTime end) {
        return repository.sumCostsByDateRange(start, end);
    }

    public BigDecimal getCostByTypeAndDateRange(EquipmentType type, LocalDateTime start, LocalDateTime end) {
        return repository.sumCostsByTypeAndDateRange(type, start, end);
    }
}
