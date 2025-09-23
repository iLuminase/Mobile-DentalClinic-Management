package com.dentalclinic.dto;

import com.dentalclinic.entity.Appointment;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AppointmentDTO {
    private Long id;
    
    @NotNull(message = "Customer ID is required")
    private Long customerId;
    
    @NotNull(message = "Employee ID is required")
    private Long employeeId;
    
    // For response DTOs, include names for better UI display
    private String customerName;
    private String employeeName;
    
    @NotNull(message = "Appointment date and time is required")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime appointmentDateTime;
    
    private Integer durationMinutes = 60;
    private Appointment.AppointmentStatus status;
    
    @NotBlank(message = "Service type is required")
    private String serviceType;
    
    private String description;
    private String notes;
    
    @Positive(message = "Cost must be positive")
    private BigDecimal cost;

    // Constructors
    public AppointmentDTO() {}

    public AppointmentDTO(Long customerId, Long employeeId, LocalDateTime appointmentDateTime, 
                         String serviceType, String description, BigDecimal cost) {
        this.customerId = customerId;
        this.employeeId = employeeId;
        this.appointmentDateTime = appointmentDateTime;
        this.serviceType = serviceType;
        this.description = description;
        this.cost = cost;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public Long getEmployeeId() { return employeeId; }
    public void setEmployeeId(Long employeeId) { this.employeeId = employeeId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public LocalDateTime getAppointmentDateTime() { return appointmentDateTime; }
    public void setAppointmentDateTime(LocalDateTime appointmentDateTime) { this.appointmentDateTime = appointmentDateTime; }

    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    public Appointment.AppointmentStatus getStatus() { return status; }
    public void setStatus(Appointment.AppointmentStatus status) { this.status = status; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }
}