package com.dentalclinic.dentalclinic_api.enums;


// Enum quản lý các vai trò trong hệ thống
public enum RoleEnum {
    ADMIN(1L, "ROLE_ADMIN", "Quản trị viên hệ thống"),
    DOCTOR(2L, "ROLE_DOCTOR", "Bác sĩ nha khoa"),
    RECEPTIONIST(3L, "ROLE_RECEPTIONIST", "Lễ tân"),
    VIEWER(4L, "ROLE_VIEWER", "Người dùng chỉ xem"),
    PENDING_USER(5L, "ROLE_PENDING_USER", "Người dùng chờ duyệt");

    private final Long id; // ID của vai trò
    private final String roleName; // Tên vai trò
    private final String description; // Mô tả vai trò

    RoleEnum(Long id, String roleName, String description) {
        this.id = id;
        this.roleName = roleName;
        this.description = description;
    }

    public Long getId() {
        return id;
    }

    public String getRoleName() {
        return roleName;
    }

    public String getDescription() {
        return description;
    }

    // Lấy vai trò mặc định cho user mới
    public static RoleEnum getDefaultRole() {
        return PENDING_USER;
    }

    // Tìm vai trò theo tên
    public static RoleEnum fromRoleName(String roleName) {
        for (RoleEnum role : values()) {
            if (role.getRoleName().equals(roleName)) {
                return role;
            }
        }
        return null;
    }

    // Tìm vai trò theo ID
    public static RoleEnum fromId(Long id) {
        for (RoleEnum role : values()) {
            if (role.getId().equals(id)) {
                return role;
            }
        }
        return null;
    }
}
