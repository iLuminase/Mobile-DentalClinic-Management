package com.dentalclinic.dentalclinic_api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role;

    @Column(nullable = true)
    private String fullName;

    @Column(nullable = true) // Made nullable for easier testing
    private Date dateOfBirth;

    //thời gian tạo tk
    @Column(nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;

    private boolean active = true;

    // Pre-persist method to set creation date automatically
    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }
}
