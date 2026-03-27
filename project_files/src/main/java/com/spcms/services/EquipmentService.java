package com.spcms.services;

import com.spcms.models.Equipment;
import com.spcms.repositories.EquipmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class EquipmentService {

    @Autowired
    private EquipmentRepository equipmentRepository;

    // ==================== CRUD ====================

    public Equipment createEquipment(Equipment equipment) {
        return equipmentRepository.save(equipment);
    }

    public Optional<Equipment> getEquipmentById(Long id) {
        return equipmentRepository.findById(id);
    }

    public Optional<Equipment> getEquipmentByAssetTag(String assetTag) {
        return equipmentRepository.findByAssetTagNumber(assetTag);
    }

    public List<Equipment> getAllEquipment() {
        return equipmentRepository.findAll();
    }

    public List<Equipment> getEquipmentByType(String type) {
        return equipmentRepository.findByEquipmentType(type);
    }

    public List<Equipment> getEquipmentByStatus(Equipment.MaintenanceStatus status) {
        return equipmentRepository.findByMaintenanceStatus(status);
    }

    public List<Equipment> getEquipmentByDataCenter(String dataCenterName) {
        return equipmentRepository.findByDataCenterName(dataCenterName);
    }

    public Equipment updateEquipment(Equipment equipment) {
        return equipmentRepository.save(equipment);
    }

    public void deleteEquipment(Long id) {
        equipmentRepository.deleteById(id);
    }

    // ==================== Lifecycle Queries ====================

    public List<Equipment> getWarrantyExpiring(LocalDate byDate) {
        return equipmentRepository.findWarrantyExpiring(byDate);
    }

    public List<Equipment> getEndOfLifeEquipment(LocalDate byDate) {
        return equipmentRepository.findEndOfLife(byDate);
    }

    public List<Equipment> getMaintenanceOverdue(LocalDate byDate) {
        return equipmentRepository.findMaintenanceOverdue(byDate);
    }
}
