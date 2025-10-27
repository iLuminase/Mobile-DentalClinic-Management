package com.dentalclinic.dentalclinic_api.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entity representing dental clinic appointments.
 * Business rules:
 * - Each appointment is 30 minutes by default
 * - Check for doctor time conflicts
 * - Patient must complete previous appointment before booking new one
 */
@Entity
@Table(name = "appointments")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor; // User with ROLE_DOCTOR

    @Column(nullable = false)
    private LocalDateTime appointmentDateTime; // Ngày giờ bắt đầu

    @Column(nullable = false)
    private Integer durationMinutes = 30; // Thời lượng dự kiến (mặc định 30 phút)

    @Column
    private LocalDateTime actualEndTime; // Thời gian kết thúc thực tế (có thể sớm hơn)

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AppointmentStatus status = AppointmentStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String notes; // Ghi chú từ lễ tân hoặc bệnh nhân

    @Column(columnDefinition = "TEXT")
    private String reason; // Lý do khám

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy; // RECEPTIONIST or ADMIN who created this appointment

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    /**
     * Calculate expected end time based on start time and duration.
     */
    public LocalDateTime getExpectedEndTime() {
        return appointmentDateTime.plusMinutes(durationMinutes);
    }

    /**
     * Get actual end time or expected end time if not yet ended.
     */
    public LocalDateTime getEffectiveEndTime() {
        return actualEndTime != null ? actualEndTime : getExpectedEndTime();
    }
}
