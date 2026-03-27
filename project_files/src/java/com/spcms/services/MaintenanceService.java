package com.spcms.services;

import com.spcms.models.UpsMaintenance;
import com.spcms.models.CoolingMaintenance;
import com.spcms.repositories.UpsMaintenanceRepository;
import com.spcms.repositories.CoolingMaintenanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class MaintenanceService {

    @Autowired
    private UpsMaintenanceRepository upsMaintenanceRepository;

    @Autowired
    private CoolingMaintenanceRepository coolingMaintenanceRepository;

    // ==================== UPS Maintenance ====================

    public UpsMaintenance scheduleUpsMaintenance(UpsMaintenance maintenance) {
        return upsMaintenanceRepository.save(maintenance);
    }

    public Optional<UpsMaintenance> getUpsMaintenanceById(Long id) {
        return upsMaintenanceRepository.findById(id);
    }

    public List<UpsMaintenance> getAllUpsMaintenance() {
        return upsMaintenanceRepository.findAllByOrderByMaintenanceDateDesc();
    }

    public List<UpsMaintenance> getUpsMaintenanceHistory(Long upsId) {
        return upsMaintenanceRepository.findByUps_UpsIdOrderByMaintenanceDateDesc(upsId);
    }

    public List<UpsMaintenance> getOverdueUpsMaintenance() {
        return upsMaintenanceRepository.findOverdue(LocalDate.now());
    }

    public List<UpsMaintenance> getUpcomingUpsMaintenance() {
        return upsMaintenanceRepository.findUpcoming(LocalDate.now(), LocalDate.now().plusDays(30));
    }

    public List<UpsMaintenance> getUpsMaintenanceByDateRange(LocalDate start, LocalDate end) {
        return upsMaintenanceRepository.findByMaintenanceDateBetween(start, end);
    }

    public UpsMaintenance updateUpsMaintenance(UpsMaintenance maintenance) {
        return upsMaintenanceRepository.save(maintenance);
    }

    public void deleteUpsMaintenance(Long id) {
        upsMaintenanceRepository.deleteById(id);
    }

    // ==================== Cooling Maintenance ====================

    public CoolingMaintenance scheduleCoolingMaintenance(CoolingMaintenance maintenance) {
        return coolingMaintenanceRepository.save(maintenance);
    }

    public Optional<CoolingMaintenance> getCoolingMaintenanceById(Long id) {
        return coolingMaintenanceRepository.findById(id);
    }

    public List<CoolingMaintenance> getAllCoolingMaintenance() {
        return coolingMaintenanceRepository.findAllByOrderByMaintenanceDateDesc();
    }

    public List<CoolingMaintenance> getCoolingMaintenanceHistory(Long coolingId) {
        return coolingMaintenanceRepository.findByCoolingUnit_CoolingIdOrderByMaintenanceDateDesc(coolingId);
    }

    public List<CoolingMaintenance> getOverdueCoolingMaintenance() {
        return coolingMaintenanceRepository.findOverdue(LocalDate.now());
    }

    public List<CoolingMaintenance> getUpcomingCoolingMaintenance() {
        return coolingMaintenanceRepository.findUpcoming(LocalDate.now(), LocalDate.now().plusDays(30));
    }

    public List<CoolingMaintenance> getCoolingMaintenanceByDateRange(LocalDate start, LocalDate end) {
        return coolingMaintenanceRepository.findByMaintenanceDateBetween(start, end);
    }

    public CoolingMaintenance updateCoolingMaintenance(CoolingMaintenance maintenance) {
        return coolingMaintenanceRepository.save(maintenance);
    }

    public void deleteCoolingMaintenance(Long id) {
        coolingMaintenanceRepository.deleteById(id);
    }

    // ==================== Report Statistics ====================

    public long getTotalUpsMaintenanceCount() {
        return upsMaintenanceRepository.count();
    }

    public long getTotalCoolingMaintenanceCount() {
        return coolingMaintenanceRepository.count();
    }

    public long getUpsPreventiveCount() {
        return upsMaintenanceRepository.countByMaintenanceType(UpsMaintenance.MaintenanceType.PREVENTIVE);
    }

    public long getUpsCorrectiveCount() {
        return upsMaintenanceRepository.countByMaintenanceType(UpsMaintenance.MaintenanceType.CORRECTIVE);
    }

    public long getCoolingPreventiveCount() {
        return coolingMaintenanceRepository.countByMaintenanceType(CoolingMaintenance.MaintenanceType.PREVENTIVE);
    }

    public long getCoolingCorrectiveCount() {
        return coolingMaintenanceRepository.countByMaintenanceType(CoolingMaintenance.MaintenanceType.CORRECTIVE);
    }

    // ==================== Quarterly Scheduling ====================

    /**
     * Schedule quarterly preventive maintenance for a UPS unit.
     * Creates 4 maintenance records for the next 4 quarters.
     */
    public void scheduleQuarterlyUpsMaintenance(Long upsId, String technician, String vendor) {
        var ups = new com.spcms.models.Ups();
        ups.setUpsId(upsId);

        LocalDate now = LocalDate.now();
        for (int q = 0; q < 4; q++) {
            LocalDate maintenanceDate = now.plusMonths(3L * (q + 1));
            UpsMaintenance maint = UpsMaintenance.builder()
                    .ups(ups)
                    .maintenanceType(UpsMaintenance.MaintenanceType.PREVENTIVE)
                    .maintenanceDate(maintenanceDate)
                    .nextDueDate(maintenanceDate.plusMonths(3))
                    .technician(technician)
                    .vendor(vendor)
                    .remarks("Quarterly preventive maintenance - Q" + (q + 1))
                    .build();
            upsMaintenanceRepository.save(maint);
        }
    }

    /**
     * Schedule quarterly preventive maintenance for a Cooling unit.
     */
    public void scheduleQuarterlyCoolingMaintenance(Long coolingId, String technician, String vendor) {
        var cooling = new com.spcms.models.CoolingUnit();
        cooling.setCoolingId(coolingId);

        LocalDate now = LocalDate.now();
        for (int q = 0; q < 4; q++) {
            LocalDate maintenanceDate = now.plusMonths(3L * (q + 1));
            CoolingMaintenance maint = CoolingMaintenance.builder()
                    .coolingUnit(cooling)
                    .maintenanceType(CoolingMaintenance.MaintenanceType.PREVENTIVE)
                    .maintenanceDate(maintenanceDate)
                    .nextMaintenanceDate(maintenanceDate.plusMonths(3))
                    .technician(technician)
                    .vendor(vendor)
                    .remarks("Quarterly preventive maintenance - Q" + (q + 1))
                    .build();
            coolingMaintenanceRepository.save(maint);
        }
    }
}

