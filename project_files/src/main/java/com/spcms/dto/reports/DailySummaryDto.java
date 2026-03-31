package com.spcms.dto.reports;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DailySummaryDto {
    private BigDecimal highestTemp;
    private BigDecimal lowestTemp;
    private BigDecimal avgHumidity;
    
    private Long totalIncidents;
    private Long criticalFaults;
    private Integer totalDowntime;
    
    private String compressorStatus;
}
