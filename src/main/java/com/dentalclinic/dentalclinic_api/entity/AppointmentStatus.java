package com.dentalclinic.dentalclinic_api.entity;

/**
 * Enum representing appointment status.
 */
public enum AppointmentStatus {
    PENDING,      // Chờ xác nhận
    CONFIRMED,    // Đã xác nhận
    IN_PROGRESS,  // Đang khám
    COMPLETED,    // Hoàn thành
    CANCELLED     // Đã hủy
}
