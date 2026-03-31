package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComplianceReportDto {
    private String issueType;
    private String severity;
    private String referenceType;
    private Long referenceId;
    private String details;
    private String recommendedAction;
    private String status;
    private LocalDateTime createdAt;
}
