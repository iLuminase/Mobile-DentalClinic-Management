package com.dentalclinic.dentalclinic_api.model.enums;

/**
 * Enum for system roles
 */
public enum RoleType {
    ADMIN("Quản trị viên"),
    DIRECTOR("Giám đốc chi nhánh"),
    DOCTOR("Bác sĩ"),
    NURSE("Y tá"),
    RECEPTIONIST("Lễ tân"),
    ACCOUNTANT("Kế toán"),
    TECHNICIAN("Kỹ thuật viên");

    private final String displayName;

    RoleType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
