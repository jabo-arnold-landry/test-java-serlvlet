package com.spcms.services;

import com.spcms.models.Alert;
import com.spcms.models.CoolingMaintenance;
import com.spcms.models.UpsMaintenance;
import com.spcms.repositories.CoolingMaintenanceRepository;
import com.spcms.repositories.UpsMaintenanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Scheduled service that automatically generates maintenance reminders.
 * Runs daily to check for upcoming and overdue maintenance,
 * creating alerts via the AlertService.
 */
@Service
@Transactional
public class MaintenanceReminderService {

    @Autowired
    private UpsMaintenanceRepository upsMaintenanceRepository;

    @Autowired
    private CoolingMaintenanceRepository coolingMaintenanceRepository;

    @Autowired
    private AlertService alertService;

    /**
     * Run every day at 7:00 AM to check for upcoming and overdue maintenance.
     * Creates MAINTENANCE_DUE alerts for any maintenance that is:
     * - Overdue (next due date has passed)
     * - Due within the next 7 days (upcoming reminder)
     */
    @Scheduled(cron = "0 0 7 * * *")
    public void generateMaintenanceReminders() {
        System.out.println("[SPCMS] Running daily maintenance reminder check...");

        LocalDate today = LocalDate.now();
        LocalDate upcomingWindow = today.plusDays(7);

        // === UPS Maintenance Reminders ===
        generateUpsReminders(today, upcomingWindow);

        // === Cooling Maintenance Reminders ===
        generateCoolingReminders(today, upcomingWindow);

        System.out.println("[SPCMS] Maintenance reminder check completed.");
    }

    /**
     * Check for overdue and upcoming UPS maintenance and create alerts.
     */
    private void generateUpsReminders(LocalDate today, LocalDate upcomingWindow) {
        // Overdue UPS maintenance
        List<UpsMaintenance> overdueUps = upsMaintenanceRepository.findOverdue(today);
        for (UpsMaintenance m : overdueUps) {
            String message = "UPS '" + (m.getUps() != null ? m.getUps().getAssetTag() : "ID:" + m.getMaintenanceId())
                    + "' maintenance is OVERDUE. Was due on " + m.getNextDueDate()
                    + ". Type: " + m.getMaintenanceType();
            alertService.createMaintenanceDueAlert(
                    Alert.EquipmentCategory.UPS,
                    m.getUps() != null ? m.getUps().getUpsId() : null,
                    message
            );
        }

        // Upcoming UPS maintenance (within 7 days)
        List<UpsMaintenance> upcomingUps = upsMaintenanceRepository.findUpcoming(today, upcomingWindow);
        for (UpsMaintenance m : upcomingUps) {
            String message = "UPS '" + (m.getUps() != null ? m.getUps().getAssetTag() : "ID:" + m.getMaintenanceId())
                    + "' maintenance due on " + m.getNextDueDate()
                    + ". Type: " + m.getMaintenanceType()
                    + ". Technician: " + m.getTechnician();
            alertService.createMaintenanceDueAlert(
                    Alert.EquipmentCategory.UPS,
                    m.getUps() != null ? m.getUps().getUpsId() : null,
                    message
            );
        }

        if (!overdueUps.isEmpty() || !upcomingUps.isEmpty()) {
            System.out.println("[SPCMS] UPS reminders: " + overdueUps.size() + " overdue, " + upcomingUps.size() + " upcoming.");
        }
    }

    /**
     * Check for overdue and upcoming Cooling maintenance and create alerts.
     */
    private void generateCoolingReminders(LocalDate today, LocalDate upcomingWindow) {
        // Overdue Cooling maintenance
        List<CoolingMaintenance> overdueCooling = coolingMaintenanceRepository.findOverdue(today);
        for (CoolingMaintenance m : overdueCooling) {
            String message = "Cooling Unit '" + (m.getCoolingUnit() != null ? m.getCoolingUnit().getAssetTag() : "ID:" + m.getMaintenanceId())
                    + "' maintenance is OVERDUE. Was due on " + m.getNextMaintenanceDate()
                    + ". Type: " + m.getMaintenanceType();
            alertService.createMaintenanceDueAlert(
                    Alert.EquipmentCategory.COOLING,
                    m.getCoolingUnit() != null ? m.getCoolingUnit().getCoolingId() : null,
                    message
            );
        }

        // Upcoming Cooling maintenance (within 7 days)
        List<CoolingMaintenance> upcomingCooling = coolingMaintenanceRepository.findUpcoming(today, upcomingWindow);
        for (CoolingMaintenance m : upcomingCooling) {
            String message = "Cooling Unit '" + (m.getCoolingUnit() != null ? m.getCoolingUnit().getAssetTag() : "ID:" + m.getMaintenanceId())
                    + "' maintenance due on " + m.getNextMaintenanceDate()
                    + ". Type: " + m.getMaintenanceType()
                    + ". Technician: " + m.getTechnician();
            alertService.createMaintenanceDueAlert(
                    Alert.EquipmentCategory.COOLING,
                    m.getCoolingUnit() != null ? m.getCoolingUnit().getCoolingId() : null,
                    message
            );
        }

        if (!overdueCooling.isEmpty() || !upcomingCooling.isEmpty()) {
            System.out.println("[SPCMS] Cooling reminders: " + overdueCooling.size() + " overdue, " + upcomingCooling.size() + " upcoming.");
        }
    }

    /**
     * Manually trigger reminder generation (can be called from controller).
     */
    public int generateRemindersNow() {
        LocalDate today = LocalDate.now();
        LocalDate upcomingWindow = today.plusDays(7);

        List<UpsMaintenance> overdueUps = upsMaintenanceRepository.findOverdue(today);
        List<UpsMaintenance> upcomingUps = upsMaintenanceRepository.findUpcoming(today, upcomingWindow);
        List<CoolingMaintenance> overdueCooling = coolingMaintenanceRepository.findOverdue(today);
        List<CoolingMaintenance> upcomingCooling = coolingMaintenanceRepository.findUpcoming(today, upcomingWindow);

        generateUpsReminders(today, upcomingWindow);
        generateCoolingReminders(today, upcomingWindow);

        return overdueUps.size() + upcomingUps.size() + overdueCooling.size() + upcomingCooling.size();
    }
}
