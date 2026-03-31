package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportLogFilterDto {
    private LocalDate startDate;
    private LocalDate endDate;
    private String reportType;
    private Long userId;
}
