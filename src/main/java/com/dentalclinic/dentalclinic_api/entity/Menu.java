package com.dentalclinic.dentalclinic_api.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// Entity Menu: menu items trong hệ thống
@Entity
@Table(name = "menus")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Menu {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100, columnDefinition = "NVARCHAR(100)")
    private String name; // Tên menu

    @Column(nullable = false, length = 100, columnDefinition = "NVARCHAR(100)")
    private String title; // Tiêu đề hiển thị

    @Column(length = 255, columnDefinition = "NVARCHAR(255)")
    private String path; // URL path (/users, /patients, ...)

    @Column(length = 50, columnDefinition = "NVARCHAR(50)")
    private String icon; // Icon name (material-ui, font-awesome, ...)

    @Column(nullable = false)
    private Integer orderIndex = 0; // Thứ tự hiển thị

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Menu parent; // Menu cha (cho submenu)

    @OneToMany(mappedBy = "parent", fetch = FetchType.LAZY)
    private Set<Menu> children = new HashSet<>(); // Menu con

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "menu_roles",
        joinColumns = @JoinColumn(name = "menu_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>(); // Các role có quyền truy cập

    @Column(nullable = false)
    private Boolean active = true;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
