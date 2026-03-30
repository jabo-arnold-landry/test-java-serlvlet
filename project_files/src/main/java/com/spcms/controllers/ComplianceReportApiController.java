package com.spcms.controllers;

import com.spcms.dto.reports.*;
import com.spcms.models.ReportLog;
import com.spcms.models.User;
import com.spcms.services.ComplianceReportExportService;
import com.spcms.services.ComplianceReportService;
import com.spcms.services.ReportLogService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reports")
public class ComplianceReportApiController {

    private final ComplianceReportService complianceReportService;
    private final ComplianceReportExportService exportService;
    private final ReportLogService reportLogService;

    public ComplianceReportApiController(ComplianceReportService complianceReportService,
                                         ComplianceReportExportService exportService,
                                         ReportLogService reportLogService) {
        this.complianceReportService = complianceReportService;
        this.exportService = exportService;
        this.reportLogService = reportLogService;
    }

    @GetMapping("/equipment-health")
    public ReportResponseDto<EquipmentHealthReportDto> equipmentHealth(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String equipmentType,
            @RequestParam(required = false) String branch,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String technician,
            @RequestParam(required = false) Integer highRiskThreshold,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "equipment-health");
        return complianceReportService.getEquipmentHealthReport(filters(startDate, endDate, equipmentType, branch, location, technician, null, highRiskThreshold, null));
    }

    @GetMapping("/maintenance")
    public ReportResponseDto<MaintenanceHistoryReportDto> maintenance(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String equipmentType,
            @RequestParam(required = false) String branch,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String technician,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "maintenance");
        return complianceReportService.getMaintenanceHistoryReport(filters(startDate, endDate, equipmentType, branch, location, technician, null, null, null));
    }

    @GetMapping("/incidents")
    public ReportResponseDto<IncidentDowntimeReportDto> incidents(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String equipmentType,
            @RequestParam(required = false) String technician,
            @RequestParam(required = false) Integer downtimeThreshold,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "incidents");
        return complianceReportService.getIncidentDowntimeReport(filters(startDate, endDate, equipmentType, null, null, technician, null, null, downtimeThreshold));
    }

    @GetMapping("/shift/{id}")
    public ReportResponseDto<ShiftTechnicianReportDto> shiftReport(
            @PathVariable("id") Long id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String technician,
            @RequestParam(required = false) Long technicianId,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "shift");
        return complianceReportService.getShiftTechnicianReport(id, filters(startDate, endDate, null, null, null, technician, technicianId, null, null));
    }

    @GetMapping("/daily")
    public ReportResponseDto<DailyConsolidatedReportDto> daily(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "false") boolean autoGenerate,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "daily");
        return complianceReportService.getDailyConsolidatedReport(filters(startDate, endDate, null, null, null, null, null, null, null), autoGenerate);
    }

    @GetMapping("/compliance")
    public ReportResponseDto<ComplianceReportDto> compliance(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String branch,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) Integer highRiskThreshold,
            @RequestParam(required = false) Integer downtimeThreshold,
            Authentication authentication) {
        enforceTechnicianScope(authentication, "compliance");
        return complianceReportService.getComplianceReport(filters(startDate, endDate, null, branch, location, null, null, highRiskThreshold, downtimeThreshold));
    }

    @GetMapping("/logs")
    public java.util.List<ReportLog> logs(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String reportType,
            @RequestParam(required = false) Long userId,
            Authentication authentication) {
        ReportLogFilterDto filter = ReportLogFilterDto.builder()
                .startDate(startDate)
                .endDate(endDate)
                .reportType(reportType)
                .userId(userId)
                .build();

        User currentUser = authentication != null
                ? reportLogService.findUserByUsername(authentication.getName()).orElse(null)
                : null;

        return reportLogService.getLogs(filter, currentUser);
    }

    @GetMapping("/export")
    public ResponseEntity<byte[]> export(
            @RequestParam String reportType,
            @RequestParam(defaultValue = "csv") String format,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String equipmentType,
            @RequestParam(required = false) String branch,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String technician,
            @RequestParam(required = false) Long technicianId,
            @RequestParam(required = false) Long shiftId,
            @RequestParam(required = false) Integer highRiskThreshold,
            @RequestParam(required = false) Integer downtimeThreshold,
            @RequestParam(defaultValue = "false") boolean autoGenerate,
            Authentication authentication
    ) throws IOException {
        enforceTechnicianScope(authentication, reportType);

        ReportFilterDto filter = filters(startDate, endDate, equipmentType, branch, location, technician, technicianId, highRiskThreshold, downtimeThreshold);
        ComplianceReportExportService.ExportPayload payload = exportService.export(
                reportType,
                format,
                filter,
                shiftId,
                autoGenerate,
                authentication != null ? authentication.getName() : null
        );

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + payload.fileName())
                .contentType(MediaType.parseMediaType(payload.contentType()))
                .body(payload.body());
    }

    private void enforceTechnicianScope(Authentication authentication, String reportType) {
        if (authentication == null) {
            return;
        }

        Set<String> roles = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toSet());

        if (roles.contains("ROLE_TECHNICIAN")) {
            String normalized = reportType == null ? "" : reportType.toLowerCase();
            if (!("shift".equals(normalized) || "maintenance".equals(normalized))) {
                throw new org.springframework.security.access.AccessDeniedException(
                        "Technician access is limited to shift and maintenance reports.");
            }
        }
    }

    private ReportFilterDto filters(LocalDate startDate,
                                    LocalDate endDate,
                                    String equipmentType,
                                    String branch,
                                    String location,
                                    String technician,
                                    Long technicianId,
                                    Integer highRiskThreshold,
                                    Integer downtimeThreshold) {
        return ReportFilterDto.builder()
                .startDate(startDate)
                .endDate(endDate)
                .equipmentType(equipmentType)
                .branch(branch)
                .location(location)
                .technician(technician)
                .technicianId(technicianId)
                .highRiskThreshold(highRiskThreshold == null ? 3 : highRiskThreshold)
                .downtimeThreshold(downtimeThreshold == null ? 120 : downtimeThreshold)
                .build();
    }
}
