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
