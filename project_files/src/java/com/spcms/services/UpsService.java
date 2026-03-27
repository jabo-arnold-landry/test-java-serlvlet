package com.spcms.services;

import com.spcms.models.Ups;
import com.spcms.models.UpsBattery;
import com.spcms.repositories.UpsRepository;
import com.spcms.repositories.UpsBatteryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UpsService {

    @Autowired
    private UpsRepository upsRepository;

    @Autowired
    private UpsBatteryRepository upsBatteryRepository;

    // ==================== UPS CRUD ====================

    public Ups createUps(Ups ups) {
        return upsRepository.save(ups);
    }

    public Optional<Ups> getUpsById(Long id) {
        return upsRepository.findById(id);
    }

    public Optional<Ups> getUpsByAssetTag(String assetTag) {
        return upsRepository.findByAssetTag(assetTag);
    }

    public List<Ups> getAllUps() {
        return upsRepository.findAll();
    }

    public List<Ups> getUpsByStatus(Ups.UpsStatus status) {
        return upsRepository.findByStatus(status);
    }

    public List<Ups> getUpsByLocation(String room) {
        return upsRepository.findByLocationRoom(room);
    }

    public Ups updateUps(Ups ups) {
        return upsRepository.save(ups);
    }

    public void deleteUps(Long id) {
        upsRepository.deleteById(id);
    }

    // ==================== Overload Detection ====================

    public List<Ups> getOverloadedUps(BigDecimal threshold) {
        return upsRepository.findOverloaded(threshold);
    }

    public List<Ups> getUpsOnBypass() {
        return upsRepository.findOnBypass();
    }

    // ==================== Battery Management ====================

    public UpsBattery addBattery(UpsBattery battery) {
        return upsBatteryRepository.save(battery);
    }

    public List<UpsBattery> getBatteriesByUpsId(Long upsId) {
        return upsBatteryRepository.findByUps_UpsId(upsId);
    }

    public List<UpsBattery> getUnhealthyBatteries() {
        return upsBatteryRepository.findUnhealthyBatteries();
    }

    public List<UpsBattery> getBatteriesDueForReplacement() {
        return upsBatteryRepository.findDueForReplacement(LocalDate.now());
    }

    public UpsBattery updateBatteryHealth(Long batteryId, UpsBattery.BatteryHealthStatus status) {
        UpsBattery battery = upsBatteryRepository.findById(batteryId)
                .orElseThrow(() -> new RuntimeException("Battery not found: " + batteryId));
        battery.setBatteryHealthStatus(status);
        return upsBatteryRepository.save(battery);
    }
}
