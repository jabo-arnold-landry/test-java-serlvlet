package com.spcms.services;

import com.spcms.models.CoolingUnit;
import com.spcms.repositories.CoolingUnitRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CoolingService {

    @Autowired
    private CoolingUnitRepository coolingUnitRepository;

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
}
