package com.spcms.dto.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportResponseDto<T> {
    private String reportName;
    private LocalDateTime generatedAt;
    private ReportFilterDto filters;
    private List<T> rows;
    private Map<String, Object> summary;
}
