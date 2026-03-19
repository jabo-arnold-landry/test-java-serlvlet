package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

/**
 * Tracks when a visitor record is deleted by Security,
 * including the reason. Managers can view this log.
 */
@Entity
@Table(name = "visitor_deletion_log")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class VisitorDeletionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Visitor info preserved for history (visitor itself will be deleted)
    @Column(name = "visitor_name", nullable = false, length = 100)
    private String visitorName;

    @Column(name = "visitor_ref", length = 50)
    private String visitorRef;

    @Column(name = "visit_date")
    private java.time.LocalDate visitDate;

    @Column(name = "was_approved")
    private Boolean wasApproved;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deleted_by")
    private User deletedBy;

    @Column(name = "deletion_reason", nullable = false, columnDefinition = "TEXT")
    private String deletionReason;

    @Column(name = "deleted_at", updatable = false)
    private LocalDateTime deletedAt;

    @PrePersist
    protected void onCreate() {
        deletedAt = LocalDateTime.now();
    }
}
