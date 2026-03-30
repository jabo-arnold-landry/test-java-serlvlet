package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "alert_acknowledgments",
        uniqueConstraints = @UniqueConstraint(name = "uk_alert_user_ack", columnNames = {"alert_id", "user_id"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlertAcknowledgment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ack_id")
    private Long ackId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alert_id", nullable = false)
    private Alert alert;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "acknowledged_at", nullable = false)
    private LocalDateTime acknowledgedAt;

    @PrePersist
    protected void onCreate() {
        if (acknowledgedAt == null) {
            acknowledgedAt = LocalDateTime.now();
        }
    }
}
