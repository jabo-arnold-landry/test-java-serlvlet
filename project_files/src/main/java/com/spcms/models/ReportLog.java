package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "report_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReportLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @Column(name = "report_type", nullable = false, length = 80)
    private String reportType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "generated_by")
    private User generatedBy;

    @Column(name = "file_format", nullable = false, length = 10)
    private String fileFormat;

    @Column(name = "file_path", length = 500)
    private String filePath;

    @Column(name = "filters_used", columnDefinition = "TEXT")
    private String filtersUsed;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ExportStatus status;

    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt;

    public enum ExportStatus {
        SUCCESS,
        FAILED
    }

    @PrePersist
    protected void onCreate() {
        generatedAt = LocalDateTime.now();
    }
}
