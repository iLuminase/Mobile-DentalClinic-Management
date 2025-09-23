package com.dentalclinic.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "treatments")
public class Treatment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "appointment_id", nullable = false)
    @NotNull(message = "Appointment is required")
    private Appointment appointment;

    @NotBlank(message = "Treatment name is required")
    @Column(name = "treatment_name", nullable = false)
    private String treatmentName;

    @Column(name = "description", length = 1000)
    private String description;

    @Column(name = "tooth_number")
    private String toothNumber;

    @Positive(message = "Cost must be positive")
    @Column(name = "cost", precision = 10, scale = 2)
    private BigDecimal cost;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TreatmentStatus status = TreatmentStatus.PLANNED;

    @Column(name = "notes", length = 1000)
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Constructors
    public Treatment() {}

    public Treatment(Appointment appointment, String treatmentName, String description, 
                    String toothNumber, BigDecimal cost) {
        this.appointment = appointment;
        this.treatmentName = treatmentName;
        this.description = description;
        this.toothNumber = toothNumber;
        this.cost = cost;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Appointment getAppointment() { return appointment; }
    public void setAppointment(Appointment appointment) { this.appointment = appointment; }

    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getToothNumber() { return toothNumber; }
    public void setToothNumber(String toothNumber) { this.toothNumber = toothNumber; }

    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }

    public TreatmentStatus getStatus() { return status; }
    public void setStatus(TreatmentStatus status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public enum TreatmentStatus {
        PLANNED, IN_PROGRESS, COMPLETED, CANCELLED
    }
}