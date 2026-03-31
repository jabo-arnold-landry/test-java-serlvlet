package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportFilterDto {
    private LocalDate startDate;
    private LocalDate endDate;
    private String equipmentType;
    private String branch;
    private String location;
    private String technician;
    private Long technicianId;
    private Integer highRiskThreshold;
    private Integer downtimeThreshold;
}
