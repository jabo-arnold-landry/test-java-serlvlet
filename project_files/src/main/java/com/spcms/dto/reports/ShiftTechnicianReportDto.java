package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShiftTechnicianReportDto {
    private Long reportId;
    private String technician;
    private String shiftType;
    private LocalDate shiftDate;
    private Integer incidentsHandled;
    private Integer downtimeDurationMin;
    private String maintenancePerformed;
    private String systemStatusSummary;
    private String pendingIssues;
    private String recommendations;
}
