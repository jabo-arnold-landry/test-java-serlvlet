package com.spcms.services;

import com.spcms.models.CoolingUnit;
import com.spcms.models.CoolingAlarmLog;
import com.spcms.repositories.CoolingUnitRepository;
import com.spcms.repositories.CoolingAlarmLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CoolingService {

    @Autowired
    private CoolingUnitRepository coolingUnitRepository;

    @Autowired
    private CoolingAlarmLogRepository coolingAlarmLogRepository;

    // ==================== Cooling Unit CRUD ====================

    public CoolingUnit createCoolingUnit(CoolingUnit coolingUnit) {
        return coolingUnitRepository.save(coolingUnit);
    }

    public Optional<CoolingUnit> getCoolingUnitById(Long id) {
        return coolingUnitRepository.findById(id);
    }

    public List<CoolingUnit> getAllCoolingUnits() {
        return coolingUnitRepository.findAll();
    }

    public List<CoolingUnit> getCoolingUnitsByStatus(CoolingUnit.CoolingStatus status) {
        return coolingUnitRepository.findByStatus(status);
    }

    public List<CoolingUnit> getCoolingUnitsAboveTemp(BigDecimal threshold) {
        return coolingUnitRepository.findHighTemperature(threshold);
    }

    public CoolingUnit updateCoolingUnit(CoolingUnit coolingUnit) {
        return coolingUnitRepository.save(coolingUnit);
    }

    public void deleteCoolingUnit(Long id) {
        coolingUnitRepository.deleteById(id);
    }

    // ==================== Alarm Management ====================

    public CoolingAlarmLog logAlarm(CoolingAlarmLog alarm) {
        return coolingAlarmLogRepository.save(alarm);
    }

    public List<CoolingAlarmLog> getAlarmsByCoolingUnit(Long coolingId) {
        return coolingAlarmLogRepository.findByCoolingUnit_CoolingIdOrderByAlarmTimeDesc(coolingId);
    }

    public List<CoolingAlarmLog> getUnresolvedAlarms() {
        return coolingAlarmLogRepository.findByResolutionTimeIsNull();
    }

    public CoolingAlarmLog resolveAlarm(Long alarmId, String resolvedBy) {
        CoolingAlarmLog alarm = coolingAlarmLogRepository.findById(alarmId)
                .orElseThrow(() -> new RuntimeException("Alarm not found: " + alarmId));
        alarm.setResolvedBy(resolvedBy);
        alarm.setResolutionTime(LocalDateTime.now());
        return coolingAlarmLogRepository.save(alarm);
    }

    public List<CoolingAlarmLog> getAlarmsByDateRange(LocalDateTime start, LocalDateTime end) {
        return coolingAlarmLogRepository.findByAlarmTimeBetween(start, end);
    }
}
