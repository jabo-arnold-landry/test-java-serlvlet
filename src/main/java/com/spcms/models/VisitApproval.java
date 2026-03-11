package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "visit_approvals")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class VisitApproval {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "approval_id")
    private Long approvalId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "visitor_id", nullable = false)
    private Visitor visitor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private ApprovalStatus status = ApprovalStatus.PENDING;

    @Column(name = "decision_time")
    private LocalDateTime decisionTime;

    @Column(name = "approved_duration_hours")
    private Integer approvedDurationHours;

    @Column(columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "notification_sent")
    private Boolean notificationSent = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum ApprovalStatus {
        PENDING, APPROVED, REJECTED
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
