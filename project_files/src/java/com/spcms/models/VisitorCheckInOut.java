package com.spcms.models;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "visitor_check_in_out")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class VisitorCheckInOut {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "check_id")
    private Long checkId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "visitor_id", nullable = false)
    private Visitor visitor;

    @Column(name = "check_in_time")
    private LocalDateTime checkInTime;

    @Column(name = "check_out_time")
    private LocalDateTime checkOutTime;

    @Column(name = "temporary_badge", length = 50)
    private String temporaryBadge;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escort_id")
    private User escort;

    @Column(name = "equipment_confirmed_out")
    private Boolean equipmentConfirmedOut = false;

    @Column(name = "visit_closed")
    private Boolean visitClosed = false;

    @Column(columnDefinition = "TEXT")
    private String remarks;
}
