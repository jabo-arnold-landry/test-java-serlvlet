package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
