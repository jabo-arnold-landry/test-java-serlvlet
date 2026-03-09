package com.spcms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "shift_handover_notes")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class ShiftHandoverNote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "note_id")
    private Long noteId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shift_report_id", nullable = false)
    private ShiftReport shiftReport;

    @NotBlank
    @Column(name = "system_status_summary", nullable = false, columnDefinition = "TEXT")
    private String systemStatusSummary;

    @Column(name = "pending_issues", columnDefinition = "TEXT")
    private String pendingIssues;

    @Column(columnDefinition = "TEXT")
    private String recommendations;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
