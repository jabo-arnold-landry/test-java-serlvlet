package com.spcms.repositories;

import com.spcms.models.Equipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EquipmentRepository extends JpaRepository<Equipment, Long> {
    Optional<Equipment> findByAssetTagNumber(String assetTagNumber);
    Optional<Equipment> findBySerialNumber(String serialNumber);
    List<Equipment> findByEquipmentType(String type);
    List<Equipment> findByMaintenanceStatus(Equipment.MaintenanceStatus status);
    List<Equipment> findByDataCenterName(String dataCenterName);
    List<Equipment> findByRackNumber(String rackNumber);

    @Query("SELECT e FROM Equipment e WHERE e.warrantyExpiryDate <= :date")
    List<Equipment> findWarrantyExpiring(LocalDate date);

    @Query("SELECT e FROM Equipment e WHERE e.endOfLife <= :date")
    List<Equipment> findEndOfLife(LocalDate date);

    @Query("SELECT e FROM Equipment e WHERE e.nextMaintenanceDue <= :date")
    List<Equipment> findMaintenanceOverdue(LocalDate date);
}
