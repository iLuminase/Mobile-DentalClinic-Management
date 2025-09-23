package com.dentalclinic.dto;

import com.dentalclinic.entity.Employee;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class EmployeeDTO {
    private Long id;
    
    @NotBlank(message = "First name is required")
    @Size(max = 50)
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(max = 50)
    private String lastName;
    
    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    private String email;
    
    @NotBlank(message = "Phone number is required")
    private String phoneNumber;
    
    private Employee.Role role;
    private Employee.EmployeeStatus status;
    private String specialization;
    private String licenseNumber;

    // Constructors
    public EmployeeDTO() {}

    public EmployeeDTO(String firstName, String lastName, String email, String phoneNumber, 
                      Employee.Role role, String specialization, String licenseNumber) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.role = role;
        this.specialization = specialization;
        this.licenseNumber = licenseNumber;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Employee.Role getRole() { return role; }
    public void setRole(Employee.Role role) { this.role = role; }

    public Employee.EmployeeStatus getStatus() { return status; }
    public void setStatus(Employee.EmployeeStatus status) { this.status = status; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) { this.licenseNumber = licenseNumber; }
}