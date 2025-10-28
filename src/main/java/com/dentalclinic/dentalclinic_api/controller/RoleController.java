package com.dentalclinic.dentalclinic_api.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.dentalclinic.dentalclinic_api.dto.RoleResponse;
import com.dentalclinic.dentalclinic_api.service.RoleService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * REST Controller quản lý vai trò.
 * Quản lý các roles trong hệ thống (ADMIN, DOCTOR, RECEPTIONIST, VIEWER, PENDING_USER).
 */
@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
@Slf4j
public class RoleController {

    private final RoleService roleService;

    /**
     * Lấy tất cả roles.
     * GET /api/roles
     * Trả về List<RoleResponse> với đầy đủ thông tin
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoleResponse>> getAllRoles() {
        log.info("Lấy danh sách tất cả vai trò");
        List<RoleResponse> roles = roleService.getAllRoles();
        return ResponseEntity.ok(roles);
    }

    /**
     * Lấy tên tất cả roles (chỉ trả về List<String>).
     * GET /api/roles/names
     * Dùng cho mobile/dropdown
     */
    @GetMapping("/names")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<String>> getAllRoleNames() {
        log.info("Lấy danh sách tên vai trò");
        List<String> roleNames = roleService.getAllRoleNames();
        return ResponseEntity.ok(roleNames);
    }

    /**
     * Lấy Map của roles (ID -> Tên).
     * GET /api/roles/map
     * Trả về: {"1": "ROLE_ADMIN", "2": "ROLE_DOCTOR", ...}
     * Dùng cho Frontend khi thêm/sửa menu - cần biết ID để gửi trong roleIds[]
     */
    @GetMapping("/map")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<java.util.Map<Long, String>> getRolesMap() {
        log.info("Lấy Map ID -> Tên vai trò");
        java.util.Map<Long, String> rolesMap = roleService.getRolesMap();
        return ResponseEntity.ok(rolesMap);
    }

    /**
     * Lấy role theo ID.
     * GET /api/roles/{id}
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<RoleResponse> getRoleById(@PathVariable Long id) {
        log.info("Lấy vai trò với ID: {}", id);
        RoleResponse role = roleService.getRoleById(id);
        return ResponseEntity.ok(role);
    }

    /**
     * Lấy tất cả roles đang hoạt động.
     * GET /api/roles/active
     */
    @GetMapping("/active")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<RoleResponse>> getActiveRoles() {
        log.info("Lấy danh sách vai trò đang hoạt động");
        List<RoleResponse> roles = roleService.getActiveRoles();
        return ResponseEntity.ok(roles);
    }
}
