package com.spcms.services;

import com.spcms.dto.reports.ReportFilterDto;
import com.spcms.models.User;
import com.spcms.repositories.UserRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Component
public class DailyReportEmailScheduler {

    private static final Logger log = LoggerFactory.getLogger(DailyReportEmailScheduler.class);

    private final ComplianceReportExportService exportService;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;

    @Value("${report.daily.email.enabled:true}")
    private boolean dailyEmailEnabled;

    @Value("${report.daily.email.zone:Africa/Nairobi}")
    private String scheduleZone;

    public DailyReportEmailScheduler(ComplianceReportExportService exportService,
                                     UserRepository userRepository,
                                     JavaMailSender mailSender) {
        this.exportService = exportService;
        this.userRepository = userRepository;
        this.mailSender = mailSender;
    }

    @Scheduled(cron = "${report.daily.email.cron:0 0 18 * * *}", zone = "${report.daily.email.zone:Africa/Nairobi}")
    public void emailDailyConsolidatedReportToManagers() {
        if (!dailyEmailEnabled) {
            return;
        }

        LocalDate reportDate = LocalDate.now(ZoneId.of(scheduleZone));
        List<User> managers = userRepository.findByRole(User.Role.MANAGER).stream()
                .filter(User::isIsActive)
                .filter(u -> u.getEmail() != null && !u.getEmail().isBlank())
                .toList();

        if (managers.isEmpty()) {
            log.info("No active managers with email found for daily report distribution.");
            return;
        }

        try {
            ComplianceReportExportService.ExportPayload payload = exportService.export(
                    "daily",
                    "pdf",
                    ReportFilterDto.builder().startDate(reportDate).endDate(reportDate).build(),
                    null,
                    true,
                    "system"
            );

            for (User manager : managers) {
                try {
                    sendReportEmail(manager.getEmail(), reportDate, payload.fileName(), payload.body());
                } catch (Exception ex) {
                    log.error("Failed to email daily report to {}: {}", manager.getEmail(), ex.getMessage(), ex);
                }
            }
        } catch (Exception ex) {
            log.error("Failed to generate daily consolidated PDF report for email: {}", ex.getMessage(), ex);
        }
    }

    private void sendReportEmail(String to, LocalDate reportDate, String fileName, byte[] pdfBytes) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setTo(to);
        helper.setSubject("SPCMS Daily Consolidated Report - " + reportDate);
        helper.setText("Please find attached the daily consolidated SPCMS report for " + reportDate + ".");
        helper.addAttachment(fileName, new org.springframework.core.io.ByteArrayResource(pdfBytes));
        mailSender.send(message);
    }
}
