package com.dentalclinic.dentalclinic_api.enums;

/**
 * Enum for system roles with their IDs and descriptions.
 */
public enum RoleEnum {
    ADMIN(1L, "ROLE_ADMIN", "Quản trị viên hệ thống"),
    DOCTOR(2L, "ROLE_DOCTOR", "Bác sĩ nha khoa"),
    RECEPTIONIST(3L, "ROLE_RECEPTIONIST", "Lễ tân"),
    VIEWER(4L, "ROLE_VIEWER", "Người dùng chỉ xem"),
    PENDING_USER(5L, "ROLE_PENDING_USER", "Người dùng chờ duyệt");

    private final Long id;
    private final String roleName;
    private final String description;

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

    /**
     * Get default role for new user registration.
     * @return PENDING_USER role
     */
    public static RoleEnum getDefaultRole() {
        return PENDING_USER;
    }

    /**
     * Find RoleEnum by role name.
     * @param roleName the role name (e.g., "ROLE_ADMIN")
     * @return RoleEnum or null if not found
     */
    public static RoleEnum fromRoleName(String roleName) {
        for (RoleEnum role : values()) {
            if (role.getRoleName().equals(roleName)) {
                return role;
            }
        }
        return null;
    }

    /**
     * Find RoleEnum by ID.
     * @param id the role ID
     * @return RoleEnum or null if not found
     */
    public static RoleEnum fromId(Long id) {
        for (RoleEnum role : values()) {
            if (role.getId().equals(id)) {
                return role;
            }
        }
        return null;
    }
}
