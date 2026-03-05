package com.spcms.services;

import com.spcms.models.MonitoringLog;
import com.spcms.repositories.MonitoringLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class MonitoringService {

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

    // ==================== Manual Reading CRUD ====================

    public MonitoringLog recordReading(MonitoringLog log) {
        return monitoringLogRepository.save(log);
    }

    public Optional<MonitoringLog> getReadingById(Long id) {
        return monitoringLogRepository.findById(id);
    }

    public List<MonitoringLog> getAllReadings() {
        return monitoringLogRepository.findAll();
    }

    public List<MonitoringLog> getReadingsForEquipment(MonitoringLog.EquipmentType type, Long equipmentId) {
        return monitoringLogRepository.findByEquipmentTypeAndEquipmentIdOrderByReadingTimeDesc(type, equipmentId);
    }

    public List<MonitoringLog> getReadingsByDateRange(LocalDateTime start, LocalDateTime end) {
        return monitoringLogRepository.findByReadingTimeBetweenOrderByReadingTimeDesc(start, end);
    }

    public List<MonitoringLog> getReadingsByTypeAndDateRange(MonitoringLog.EquipmentType type,
                                                              LocalDateTime start, LocalDateTime end) {
        return monitoringLogRepository.findByTypeAndDateRange(type, start, end);
    }

    public void deleteReading(Long id) {
        monitoringLogRepository.deleteById(id);
    }
}
