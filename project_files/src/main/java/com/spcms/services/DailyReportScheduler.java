package com.spcms.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;

/**
 * Generates daily consolidated reports automatically.
 *
 * Schedule and timezone are configurable via application.properties.
 * The scheduled job runs just after midnight and generates yesterday's report
 * to ensure the full previous day data is available.
 */
@Component
public class DailyReportScheduler {

    private static final Logger log = LoggerFactory.getLogger(DailyReportScheduler.class);

    private final ReportService reportService;

    @Value("${report.daily.auto.enabled:true}")
    private boolean autoGenerationEnabled;

    @Value("${report.daily.auto.zone:Africa/Nairobi}")
    private String scheduleZone;

    public DailyReportScheduler(ReportService reportService) {
        this.reportService = reportService;
    }

    @Scheduled(cron = "${report.daily.auto.cron:0 5 0 * * *}", zone = "${report.daily.auto.zone:Africa/Nairobi}")
    public void generatePreviousDayReport() {
        if (!autoGenerationEnabled) {
            return;
        }

        LocalDate targetDate = LocalDate.now(ZoneId.of(scheduleZone)).minusDays(1);
        reportService.generateDailyReport(targetDate);
        log.info("Auto-generated daily consolidated report for {}", targetDate);
    }

    /**
     * Startup catch-up to ensure at least one recent auto-generated report exists
     * even before the next cron window is reached.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void generatePreviousDayOnStartup() {
        if (!autoGenerationEnabled) {
            return;
        }

        LocalDate targetDate = LocalDate.now(ZoneId.of(scheduleZone)).minusDays(1);
        reportService.generateDailyReport(targetDate);
        log.info("Startup auto-generation check completed for {}", targetDate);
    }
}
