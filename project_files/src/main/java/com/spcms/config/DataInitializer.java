package com.spcms.config;

import com.spcms.models.CoolingUnit;
import com.spcms.models.Incident;
import com.spcms.models.MonitoringLog;
import com.spcms.models.User;
import com.spcms.repositories.CoolingUnitRepository;
import com.spcms.repositories.IncidentRepository;
import com.spcms.repositories.MonitoringLogRepository;
import com.spcms.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * DataInitializer: Seeds the database with a default ADMIN user on first run.
 *
 * Default credentials:
 *   Username: admin
 *   Password: admin123
 *
 * Change these credentials immediately after first login via /users.
 */
import java.util.Optional;

@Component
@Order(1)
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CoolingUnitRepository coolingUnitRepository;

    @Autowired
    private IncidentRepository incidentRepository;

    @Autowired
    private MonitoringLogRepository monitoringLogRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private com.spcms.repositories.VisitorRepository visitorRepository;

    @Autowired
    private com.spcms.repositories.VisitApprovalRepository visitApprovalRepository;

    @Autowired
    private com.spcms.repositories.VisitorCheckInOutRepository visitorCheckInOutRepository;

    @Override
    public void run(String... args) throws Exception {
        try {
            cleanupDeprecatedViewers();
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to cleanup deprecated viewers: " + e.getMessage());
        }
        seedDefaultUsers();
        seedCoolingUnits();
        seedCoolingMonitoringLogs();
        seedIncidents();
    }

    private void cleanupDeprecatedViewers() {
        // Delete all viewers as visitors no longer have self-service accounts
        List<User> viewers = userRepository.findByRole(User.Role.VIEWER);
        if (!viewers.isEmpty()) {
            System.out.println("Initiating cleanup for " + viewers.size() + " deprecated VIEWER accounts...");
            for (User viewer : viewers) {
                Long userId = viewer.getUserId();
                List<com.spcms.models.Visitor> visitors = visitorRepository.findByRequestedBy_UserId(userId);
                for (com.spcms.models.Visitor visitor : visitors) {
                    List<com.spcms.models.VisitorCheckInOut> checks = visitorCheckInOutRepository.findByVisitor_VisitorId(visitor.getVisitorId());
                    visitorCheckInOutRepository.deleteAll(checks);
                    List<com.spcms.models.VisitApproval> approvals = visitApprovalRepository.findByVisitor_VisitorId(visitor.getVisitorId());
                    visitApprovalRepository.deleteAll(approvals);
                    visitorRepository.delete(visitor);
                }
                userRepository.delete(viewer);
            }
            System.out.println("VIEWER account cleanup completed.");
        }
    }

    private void seedDefaultUsers() {
        // Only seed if no admin user exists yet
        if (!userRepository.findByUsername("admin").isPresent()) {
            User admin = User.builder()
                    .username("admin")
                    .password(passwordEncoder.encode("admin123"))
                    .email("admin@spcms.local")
                    .fullName("System Administrator")
                    .role(User.Role.ADMIN)
                    .department("IT Infrastructure")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(admin);
            System.out.println("=======================================================");
            System.out.println("  SPCMS: Default admin user created.");
            System.out.println("  Username: admin  |  Password: admin123");
            System.out.println("  Please change this password immediately after login.");
            System.out.println("=======================================================");
        }

        // Seed a default Technician user as well
        if (!userRepository.findByUsername("technician").isPresent()) {
            User tech = User.builder()
                    .username("technician")
                    .password(passwordEncoder.encode("tech123"))
                    .email("tech@spcms.local")
                    .fullName("Default Technician")
                    .role(User.Role.TECHNICIAN)
                    .department("IT Infrastructure")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(tech);
        }

        // Seed a default Manager user
        if (!userRepository.findByUsername("manager").isPresent()) {
            User mgr = User.builder()
                    .username("manager")
                    .password(passwordEncoder.encode("manager123"))
                    .email("manager@spcms.local")
                    .fullName("Default Manager")
                    .role(User.Role.MANAGER)
                    .department("Operations")
                    .branch("Main Data Center")
                    .isActive(true)
                    .build();
            userRepository.save(mgr);
        }
    }

    private void seedCoolingUnits() {
        final int targetCount = 30;
        long existingCount = coolingUnitRepository.count();
        if (existingCount >= targetCount) {
            return;
        }

        List<CoolingUnit> existing = coolingUnitRepository.findAll();
        Set<String> existingAssetTags = new HashSet<>();
        Set<String> existingSerials = new HashSet<>();
        for (CoolingUnit unit : existing) {
            if (unit.getAssetTag() != null) {
                existingAssetTags.add(unit.getAssetTag());
            }
            if (unit.getSerialNumber() != null) {
                existingSerials.add(unit.getSerialNumber());
            }
        }

        int toCreate = targetCount - (int) existingCount;
        int created = 0;
        int seed = 1;
        while (created < toCreate && seed < 1000) {
            String assetTag = String.format("CU-%03d", seed);
            String serialNumber = String.format("SN-CU-%04d", seed);
            if (existingAssetTags.contains(assetTag) || existingSerials.contains(serialNumber)) {
                seed++;
                continue;
            }

            CoolingUnit unit = buildCoolingUnit(seed, assetTag, serialNumber);
            coolingUnitRepository.save(unit);
            existingAssetTags.add(assetTag);
            existingSerials.add(serialNumber);
            created++;
            seed++;
        }
    }

    private void seedIncidents() {
        final int targetCount = 30;
        long existingCount = incidentRepository.count();
        if (existingCount >= targetCount) {
            return;
        }

        List<CoolingUnit> coolingUnits = coolingUnitRepository.findAll();
        List<User> allUsers = userRepository.findAll();
        User admin = userRepository.findByUsername("admin").orElse(null);
        User technician = userRepository.findByUsername("technician").orElse(null);
        User manager = userRepository.findByUsername("manager").orElse(null);

        List<User> reporters = new ArrayList<>();
        if (admin != null) {
            reporters.add(admin);
        }
        if (technician != null) {
            reporters.add(technician);
        }
        if (manager != null) {
            reporters.add(manager);
        }
        if (reporters.isEmpty()) {
            reporters.addAll(allUsers);
        }

        List<User> assignees = new ArrayList<>();
        if (technician != null) {
            assignees.add(technician);
        }
        if (manager != null) {
            assignees.add(manager);
        }
        if (assignees.isEmpty()) {
            assignees.addAll(allUsers);
        }

        String[] titles = {
                "Cooling temperature spike",
                "UPS battery warning",
                "Compressor stopped unexpectedly",
                "High humidity detected",
                "Power input fluctuation",
                "Airflow restriction alarm",
                "Sensor calibration needed",
                "Leak detection alert",
                "Overcurrent trip",
                "Fan speed anomaly"
        };
        String[] descriptions = {
                "Temperature exceeded safe threshold for more than 10 minutes.",
                "Battery health dropped below 60% and needs inspection.",
                "Compressor reported stop while unit remains active.",
                "Humidity levels out of target range.",
                "Input voltage fluctuated outside acceptable range.",
                "Airflow dropped below expected levels.",
                "Sensor drift detected during routine monitoring.",
                "Refrigerant pressure drop suggests possible leak.",
                "Current draw spiked beyond safe limits.",
                "Fan speed inconsistent with setpoint."
        };
        String[] rootCauses = {
                "Clogged filter",
                "Failed sensor",
                "Loose power connection",
                "Controller misconfiguration",
                "Refrigerant leak",
                "Overloaded circuit"
        };
        String[] actions = {
                "Replaced filter and verified airflow.",
                "Calibrated sensor and rechecked readings.",
                "Secured power input and retested load.",
                "Updated controller settings and rebooted unit.",
                "Topped up refrigerant and inspected seals.",
                "Balanced load across circuits."
        };

        Incident.IncidentStatus[] statusCycle = {
                Incident.IncidentStatus.IN_PROGRESS,
                Incident.IncidentStatus.IN_PROGRESS,
                Incident.IncidentStatus.RESOLVED
        };

        int toCreate = targetCount - (int) existingCount;
        for (int i = 1; i <= toCreate; i++) {
            int seed = (int) existingCount + i;
            Incident.EquipmentType equipmentType = seed % 3 == 0
                    ? Incident.EquipmentType.UPS
                    : (seed % 3 == 1 ? Incident.EquipmentType.COOLING : Incident.EquipmentType.OTHER);

            Long equipmentId = null;
            if (equipmentType == Incident.EquipmentType.COOLING && !coolingUnits.isEmpty()) {
                equipmentId = coolingUnits.get(seed % coolingUnits.size()).getCoolingId();
            } else if (equipmentType == Incident.EquipmentType.UPS) {
                equipmentId = 1000L + seed;
            }

            Incident.Severity severity = Incident.Severity.values()[seed % Incident.Severity.values().length];
            Incident.IncidentStatus status = statusCycle[seed % statusCycle.length];

            User reportedBy = reporters.isEmpty() ? null : reporters.get(seed % reporters.size());
            User assignedTo = null;
            if (!assignees.isEmpty()) {
                assignedTo = assignees.get(seed % assignees.size());
            }

            LocalDateTime downtimeStart = null;
            LocalDateTime downtimeEnd = null;
            Integer downtimeMinutes = null;
            downtimeStart = LocalDateTime.now().minusHours(1 + (seed % 72)).minusMinutes(seed % 60);
            if (status == Incident.IncidentStatus.RESOLVED) {
                downtimeMinutes = 15 + (seed % 240);
                downtimeEnd = downtimeStart.plusMinutes(downtimeMinutes);
            }

            String rootCause = (status == Incident.IncidentStatus.RESOLVED)
                    ? rootCauses[seed % rootCauses.length]
                    : null;
            String actionTaken = (status == Incident.IncidentStatus.RESOLVED)
                    ? actions[seed % actions.length]
                    : null;
            LocalDateTime resolvedAt = (status == Incident.IncidentStatus.RESOLVED)
                    ? (downtimeEnd != null ? downtimeEnd : LocalDateTime.now().minusHours(seed % 24))
                    : null;
            User resolvedBy = (status == Incident.IncidentStatus.RESOLVED)
                    ? (assignedTo != null ? assignedTo : reportedBy)
                    : null;

            Incident incident = Incident.builder()
                    .equipmentType(equipmentType)
                    .equipmentId(equipmentId)
                    .title(titles[seed % titles.length])
                    .description(descriptions[seed % descriptions.length])
                    .severity(severity)
                    .status(status)
                    .reportedBy(reportedBy)
                    .assignedTo(assignedTo)
                    .downtimeStart(downtimeStart)
                    .downtimeEnd(downtimeEnd)
                    .downtimeMinutes(downtimeMinutes)
                    .rootCause(rootCause)
                    .actionTaken(actionTaken)
                    .resolvedAt(resolvedAt)
                    .resolvedBy(resolvedBy)
                    .build();

            incidentRepository.save(incident);
        }
    }

    private void seedCoolingMonitoringLogs() {
        List<CoolingUnit> coolingUnits = coolingUnitRepository.findAll();
        if (coolingUnits.isEmpty()) {
            return;
        }

        User admin = userRepository.findByUsername("admin").orElse(null);
        User technician = userRepository.findByUsername("technician").orElse(null);
        User manager = userRepository.findByUsername("manager").orElse(null);

        List<User> recorders = new ArrayList<>();
        if (technician != null) {
            recorders.add(technician);
        }
        if (admin != null) {
            recorders.add(admin);
        }
        if (manager != null) {
            recorders.add(manager);
        }
        if (recorders.isEmpty()) {
            recorders.addAll(userRepository.findAll());
        }

        for (int i = 0; i < coolingUnits.size(); i++) {
            CoolingUnit unit = coolingUnits.get(i);
            long existing = monitoringLogRepository.countByEquipmentTypeAndEquipmentId(
                    MonitoringLog.EquipmentType.COOLING, unit.getCoolingId());
            if (existing > 0) {
                continue;
            }

            int logsPerUnit = 5;
            for (int j = 0; j < logsPerUnit; j++) {
                int seed = (i + 1) * 10 + j;
                MonitoringLog log = buildCoolingMonitoringLog(unit, recorders, seed, j);
                monitoringLogRepository.save(log);
            }
        }
    }

    private MonitoringLog buildCoolingMonitoringLog(CoolingUnit unit, List<User> recorders, int seed, int index) {
        BigDecimal baseReturn = unit.getReturnAirTemp() != null
                ? unit.getReturnAirTemp()
                : BigDecimal.valueOf(22 + (seed % 6));
        BigDecimal returnTemp = baseReturn.add(BigDecimal.valueOf((seed % 3) - 1));
        BigDecimal supplyTemp = returnTemp.subtract(BigDecimal.valueOf(6));

        BigDecimal baseHumidity = unit.getHumidityPercent() != null
                ? unit.getHumidityPercent()
                : BigDecimal.valueOf(40 + (seed % 20));
        BigDecimal humidity = baseHumidity.add(BigDecimal.valueOf((seed % 5) - 2));

        String performance = "Good";
        if (returnTemp.compareTo(new BigDecimal("28")) > 0) {
            performance = "Degraded";
        } else if (humidity.compareTo(new BigDecimal("65")) > 0 || humidity.compareTo(new BigDecimal("30")) < 0) {
            performance = "Warning";
        }

        User recorder = recorders.isEmpty() ? null : recorders.get(seed % recorders.size());

        return MonitoringLog.builder()
                .equipmentType(MonitoringLog.EquipmentType.COOLING)
                .equipmentId(unit.getCoolingId())
                .recordedBy(recorder)
                .supplyAirTemp(supplyTemp)
                .returnAirTemp(returnTemp)
                .humidityPercent(humidity)
                .coolingPerformance(performance)
                .readingTime(LocalDateTime.now().minusHours((seed % 72)).minusMinutes(index * 7L))
                .notes("Auto-seeded cooling monitoring reading")
                .build();
    }

    private CoolingUnit buildCoolingUnit(int seed, String assetTag, String serialNumber) {
        String[] brands = {"Liebert", "Stulz", "Vertiv", "Schneider", "Huawei"};
        String[] models = {"PX", "CW", "InRow", "CRV", "PDU"};
        String[] zones = {"Zone A", "Zone B", "Zone C", "Zone D", "Zone E"};
        String[] rooms = {"Room 101", "Room 102", "Room 103", "Room 201", "Room 202", "Room 203"};
        String[] refrigerants = {"R410A", "R134a", "R407C"};
        String[] airflowStates = {"OK", "LOW", "HIGH"};
        String[] fanSpeeds = {"LOW", "MEDIUM", "HIGH"};

        CoolingUnit.CoolingStatus[] statusCycle = {
                CoolingUnit.CoolingStatus.ACTIVE,
                CoolingUnit.CoolingStatus.ACTIVE,
                CoolingUnit.CoolingStatus.ACTIVE,
                CoolingUnit.CoolingStatus.FAULTY,
                CoolingUnit.CoolingStatus.UNDER_MAINTENANCE,
                CoolingUnit.CoolingStatus.DECOMMISSIONED
        };

        CoolingUnit.CoolingStatus status = statusCycle[seed % statusCycle.length];
        CoolingUnit.CompressorStatus compressorStatus =
                (status == CoolingUnit.CoolingStatus.ACTIVE && seed % 3 != 0)
                        ? CoolingUnit.CompressorStatus.RUNNING
                        : CoolingUnit.CompressorStatus.STOPPED;

        BigDecimal returnAirTemp = BigDecimal.valueOf(22 + (seed % 6));
        BigDecimal supplyAirTemp = returnAirTemp.subtract(BigDecimal.valueOf(6));
        BigDecimal roomTemp = returnAirTemp.subtract(BigDecimal.valueOf(2));

        return CoolingUnit.builder()
                .assetTag(assetTag)
                .unitName(String.format("Cooling Unit %02d", seed))
                .brand(brands[seed % brands.length])
                .model(models[seed % models.length])
                .serialNumber(serialNumber)
                .coolingCapacityKw(BigDecimal.valueOf(12 + (seed % 9)))
                .installationDate(LocalDate.now().minusDays(seed * 20L))
                .locationZone(zones[seed % zones.length])
                .locationRoom(rooms[seed % rooms.length])
                .status(status)
                .returnAirTemp(returnAirTemp)
                .supplyAirTemp(supplyAirTemp)
                .roomTemperature(roomTemp)
                .humidityPercent(BigDecimal.valueOf(35 + (seed % 25)))
                .setTemperature(BigDecimal.valueOf(22))
                .setHumidity(BigDecimal.valueOf(45))
                .airflowStatus(airflowStates[seed % airflowStates.length])
                .coolingMode(seed % 5 == 0 ? CoolingUnit.CoolingMode.MANUAL : CoolingUnit.CoolingMode.AUTO)
                .fanSpeed(fanSpeeds[seed % fanSpeeds.length])
                .compressorStatus(compressorStatus)
                .inputVoltage(BigDecimal.valueOf(380 + (seed % 2) * 5))
                .currentAmps(BigDecimal.valueOf(8 + (seed % 12)))
                .powerConsumption(BigDecimal.valueOf(5 + (seed % 6)))
                .refrigerantPressure(BigDecimal.valueOf(7 + (seed % 5)))
                .refrigerantType(refrigerants[seed % refrigerants.length])
                .filterStatus(seed % 10 == 0
                        ? CoolingUnit.FilterStatus.NEEDS_REPLACEMENT
                        : (seed % 4 == 0 ? CoolingUnit.FilterStatus.DIRTY : CoolingUnit.FilterStatus.CLEAN))
                .drainStatus(seed % 7 == 0
                        ? CoolingUnit.DrainStatus.BLOCKED
                        : CoolingUnit.DrainStatus.CLEAR)
                .build();
    }
}
