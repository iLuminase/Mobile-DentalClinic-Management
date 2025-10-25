package com.dentalclinic.dentalclinic_api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Permission entity representing system permissions
 * Structure: resource + action (e.g., APPOINTMENT_CREATE, PATIENT_READ)
 */
@Entity
@Table(name = "permissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Permission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name; // Display name: "Create Appointment"

    @Column(nullable = false, unique = true, length = 100)
    private String code; // Unique code: "APPOINTMENT_CREATE"

    @Column(nullable = false, length = 50)
    private String resource; // Resource: APPOINTMENT, PATIENT, INVOICE, REPORT, USER

    @Column(nullable = false, length = 50)
    private String action; // Action: CREATE, READ, UPDATE, DELETE, APPROVE, EXPORT

    @Column(length = 255)
    private String description;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
