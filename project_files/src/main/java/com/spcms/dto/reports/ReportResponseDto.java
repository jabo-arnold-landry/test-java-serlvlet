package com.spcms.dto.reports;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportResponseDto<T> {
    private String reportName;
    private LocalDateTime generatedAt;
    private ReportFilterDto filters;
    private List<T> rows;
    private Map<String, Object> summary;
}
