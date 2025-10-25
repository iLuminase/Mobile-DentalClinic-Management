package com.dentalclinic.dentalclinic_api.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String username;

    @Column(nullable = false)
    private String password;

    // Keycloak user ID (subject claim from JWT)
    @Column(name = "keycloak_id", unique = true, length = 100)
    private String keycloakId;

    @Column(name = "full_name", length = 255)
    private String fullName;

    @Column(length = 100)
    private String email;

    @Column(length = 20)
    private String phone;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    // Temporary field for backward compatibility - will be replaced by UserRole system
    @Column(length = 50)
    @Deprecated
    private String role;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // One-to-Many relationship with UserRole
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<UserRole> userRoles = new HashSet<>();

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }


    public String getPrimaryRole() {
        if (role != null) {
            return role;
        }
        return userRoles.stream()
                .filter(ur -> ur.isActive())
                .findFirst()
                .map(ur -> ur.getRole().getName())
                .orElse(null);
    }


    public boolean hasRole(String roleName) {
        if (role != null && role.equals(roleName)) {
            return true;
        }
        return userRoles.stream()
                .filter(ur -> ur.isActive())
                .anyMatch(ur -> ur.getRole().getName().equals(roleName));
    }


    public boolean hasRoleAtBranch(String roleName, Long branchId) {
        return userRoles.stream()
                .filter(ur -> ur.isActive())
                .filter(ur -> ur.getRole().getName().equals(roleName))
                .anyMatch(ur -> ur.getBranch() != null && ur.getBranch().getId().equals(branchId));
    }
}

