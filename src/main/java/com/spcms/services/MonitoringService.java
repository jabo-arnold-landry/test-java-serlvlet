package com.spcms.services;

import com.spcms.models.MonitoringLog;
import com.spcms.repositories.MonitoringLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spcms.models.Alert;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class MonitoringService {

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

    @Autowired
    private AlertService alertService;

    // ==================== Manual Reading CRUD ====================

    public MonitoringLog recordReading(MonitoringLog log) {
        MonitoringLog saved = monitoringLogRepository.save(log);
        checkThresholdsAndAlert(saved);
        return saved;
    }

    private void checkThresholdsAndAlert(MonitoringLog log) {
        Alert.EquipmentCategory category = log.getEquipmentType() == MonitoringLog.EquipmentType.UPS
                ? Alert.EquipmentCategory.UPS
                : Alert.EquipmentCategory.COOLING;

        if (log.getEquipmentType() == MonitoringLog.EquipmentType.COOLING) {
            // Humidity Check (Ideal: 30% - 65%)
            if (log.getHumidityPercent() != null) {
                if (log.getHumidityPercent().compareTo(new BigDecimal("65")) > 0) {
                    alertService.createHumidityAlert(category, log.getEquipmentId(), new BigDecimal("65"),
                            log.getHumidityPercent(), "above");
                } else if (log.getHumidityPercent().compareTo(new BigDecimal("30")) < 0) {
                    alertService.createHumidityAlert(category, log.getEquipmentId(), new BigDecimal("30"),
                            log.getHumidityPercent(), "below");
                }
            }
            // Temperature Check
            if (log.getReturnAirTemp() != null && log.getReturnAirTemp().compareTo(new BigDecimal("28")) > 0) {
                alertService.createHighTempAlert(category, log.getEquipmentId(), new BigDecimal("28"),
                        log.getReturnAirTemp());
            }
        } else if (log.getEquipmentType() == MonitoringLog.EquipmentType.UPS) {
            // Temperature Check
            if (log.getTemperature() != null && log.getTemperature().compareTo(new BigDecimal("35")) > 0) {
                alertService.createHighTempAlert(category, log.getEquipmentId(), new BigDecimal("35"),
                        log.getTemperature());
            }
            // Overload Check
            if (log.getLoadPercentage() != null && log.getLoadPercentage().compareTo(new BigDecimal("80")) > 0) {
                alertService.createOverloadAlert(log.getEquipmentId(), new BigDecimal("80"), log.getLoadPercentage());
            }
            // Note: Low battery is usually triggered by UPS status/voltage rather than just
            // monitoring log, but can be added here if needed.
        }
    }

    public Optional<MonitoringLog> getReadingById(Long id) {
        return monitoringLogRepository.findById(id);
    }

    public List<MonitoringLog> getAllReadings() {
        return monitoringLogRepository.findAll();
    }

    public List<MonitoringLog> getReadingsForEquipment(MonitoringLog.EquipmentType type, Long equipmentId) {
        return monitoringLogRepository.findByEquipmentTypeAndEquipmentIdOrderByCreatedAtDesc(
                type, equipmentId);
    }

    public List<MonitoringLog> getReadingsByDateRange(LocalDateTime start, LocalDateTime end) {
        return monitoringLogRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(start, end);
    }

    public List<MonitoringLog> getReadingsByTypeAndDateRange(MonitoringLog.EquipmentType type,
            LocalDateTime start, LocalDateTime end) {
        return monitoringLogRepository.findByTypeAndDateRange(type, start, end);
    }

    public void deleteReading(Long id) {
        monitoringLogRepository.deleteById(id);
    }

    public List<MonitoringLog> getReadingsForUps(Long upsId) {
        return monitoringLogRepository.findByEquipmentTypeAndEquipmentIdOrderByCreatedAtDesc(
                MonitoringLog.EquipmentType.UPS, upsId);
    }
}
