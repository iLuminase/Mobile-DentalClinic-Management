package com.dentalclinic.dentalclinic_api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;
    private String password;
    private String role; // admin, staff, doctor, etc.
    private String email;

    private String fullName;
    private String phoneNumber;
}
