package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IncidentDowntimeReportDto {
    private Long incidentId;
    private String title;
    private String equipmentType;
    private Long equipmentId;
    private String severity;
    private Integer downtimeMinutes;
    private String rootCause;
    private String status;
    private String technician;
    private LocalDateTime createdAt;
    private Boolean slaViolation;
}
