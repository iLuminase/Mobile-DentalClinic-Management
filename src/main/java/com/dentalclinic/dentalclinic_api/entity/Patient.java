package com.dentalclinic.dentalclinic_api.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

// Entity Patient: bệnh nhân (không có quyền đăng nhập)
@Entity
@Table(name = "patients")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100, columnDefinition = "NVARCHAR(100)")
    private String fullName;

    @Column(nullable = false)
    private LocalDateTime dateOfBirth;

    @Column(nullable = false, length = 20, columnDefinition = "NVARCHAR(20)")
    private String phoneNumber;

    @Column(length = 100, columnDefinition = "NVARCHAR(100)")
    private String email;

    @Column(length = 255, columnDefinition = "NVARCHAR(255)")
    private String address;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String medicalHistory;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String allergies;

    @Column(length = 100, columnDefinition = "NVARCHAR(100)")
    private String emergencyContactName;

    @Column(length = 20, columnDefinition = "NVARCHAR(20)")
    private String emergencyContactPhone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy;

    @Column(nullable = false)
    private Boolean active = true;

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
}
