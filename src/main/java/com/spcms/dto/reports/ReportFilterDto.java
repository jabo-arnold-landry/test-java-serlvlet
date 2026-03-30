package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportFilterDto {
    private LocalDate startDate;
    private LocalDate endDate;
    private String equipmentType;
    private String branch;
    private String location;
    private String technician;
    private Long technicianId;

    @Builder.Default
    private Integer highRiskThreshold = 3;

    @Builder.Default
    private Integer downtimeThreshold = 120;
}
