package com.spcms.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "visitors")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Visitor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "visitor_id")
    private Long visitorId;

    @NotBlank
    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @NotBlank
    @Column(name = "national_id_passport", nullable = false, length = 50)
    private String nationalIdPassport;

    @Column(length = 100)
    private String company;

    @Column(length = 20)
    private String phone;

    @Column(name = "purpose_of_visit", nullable = false, columnDefinition = "TEXT")
    private String purposeOfVisit;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "host_employee_id")
    private User hostEmployee;

    @Column(name = "equipment_carried", columnDefinition = "TEXT")
    private String equipmentCarried;

    @Column(name = "id_copy_path", length = 500)
    private String idCopyPath;

    @Column(name = "photo_path", length = 500)
    private String photoPath;

    @Column(name = "pass_number", unique = true, length = 50)
    private String passNumber;

    @Column(name = "visit_date", nullable = false)
    private LocalDate visitDate;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
