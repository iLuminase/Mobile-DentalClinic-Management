package com.dentalclinic.dentalclinic_api.dto;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO Menu response cho frontend (Mobile & Web)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL) // Chỉ trả về field có giá trị
public class MenuResponse {
    
    // Basic info
    private Long id;
    private String name;            // Unique identifier (e.g., "users", "dashboard")
    private String title;           // Display name (e.g., "Quản lý người dùng")
    private String path;            // Route path (e.g., "/users")
    private String icon;            // Icon name (Material Icons or custom)
    private Integer orderIndex;     // Display order
    private Long parentId;          // Parent menu ID (null for root)
    private Boolean active;         // Is menu active?
    
    // Mobile-specific fields
    private String description;     // Menu description for tooltips
    private String color;           // Theme color (hex or color name)
    private Integer badgeCount;     // Notification badge count
    private String badgeColor;      // Badge color (e.g., "red", "blue")
    private Boolean isNew;          // Show "NEW" label?
    private String iconType;        // Icon type: "material", "fontawesome", "custom"
    
    // Hierarchy
    @Builder.Default
    private List<MenuResponse> children = new ArrayList<>();  // Submenu items
    private Integer depth;          // Menu depth level (0 = root, 1 = level 1, ...)
    private Boolean hasChildren;    // Does this menu have submenus?
    
    // Permissions (for mobile to show/hide features)
    private List<String> roles;     // Required roles to access this menu
    private Boolean canView;        // User can view this menu?
    private Boolean canEdit;        // User can edit items in this menu?
    private Boolean canDelete;      // User can delete items in this menu?
    
    // Metadata for mobile
    private String target;          // Link target: "_self", "_blank", "modal", "drawer"
    private Boolean external;       // Is external link?
    private String componentName;   // Flutter widget/screen name
    private String tooltip;         // Tooltip text
}
