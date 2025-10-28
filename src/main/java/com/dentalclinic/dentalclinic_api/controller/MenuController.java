package com.dentalclinic.dentalclinic_api.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.dentalclinic.dentalclinic_api.dto.MenuRequest;
import com.dentalclinic.dentalclinic_api.dto.MenuResponse;
import com.dentalclinic.dentalclinic_api.service.MenuService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

// Controller quản lý menu và phân quyền
@RestController
@RequestMapping("/api/menus")
@RequiredArgsConstructor
public class MenuController {

    private final MenuService menuService;

    // ========== USER ENDPOINTS (Authentication required) ==========
    
    /**
     * GET /api/menus/me
     * Lấy menu hierarchy của user hiện tại (theo roles)
     * Response: Danh sách menu dạng tree với đầy đủ thông tin cho mobile
     */
    @GetMapping("/me")
    public ResponseEntity<List<MenuResponse>> getMyMenus(Authentication authentication) {
        String username = authentication.getName();
        List<MenuResponse> menus = menuService.getMenuByUsername(username);
        return ResponseEntity.ok(menus);
    }

    /**
     * GET /api/menus/flat
     * Lấy tất cả menu của user dạng flat list (không có hierarchy)
     * Hữu ích cho mobile khi cần tìm kiếm menu hoặc hiển thị breadcrumb
     */
    @GetMapping("/flat")
    public ResponseEntity<List<MenuResponse>> getMyMenusFlat(Authentication authentication) {
        String username = authentication.getName();
        List<MenuResponse> menus = menuService.getMenuFlatByUsername(username);
        return ResponseEntity.ok(menus);
    }

    /**
     * GET /api/menus/breadcrumb/{id}
     * Lấy breadcrumb path từ root đến menu cụ thể
     * Response: [Home > Users > User List]
     */
    @GetMapping("/breadcrumb/{id}")
    public ResponseEntity<List<MenuResponse>> getBreadcrumb(
            @PathVariable Long id,
            Authentication authentication) {
        String username = authentication.getName();
        List<MenuResponse> breadcrumb = menuService.getBreadcrumbPath(id, username);
        return ResponseEntity.ok(breadcrumb);
    }

    /**
     * GET /api/menus/stats
     * Lấy thống kê menu của user (số lượng menu, menu mới, notifications)
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getMenuStats(Authentication authentication) {
        String username = authentication.getName();
        Map<String, Object> stats = menuService.getMenuStatistics(username);
        return ResponseEntity.ok(stats);
    }

    // ========== ADMIN ENDPOINTS ==========
    
    /**
     * GET /api/menus
     * Lấy tất cả menu (Admin only)
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MenuResponse>> getAllMenus() {
        List<MenuResponse> menus = menuService.getAllMenus();
        return ResponseEntity.ok(menus);
    }

    /**
     * GET /api/menus/hierarchy
     * Lấy toàn bộ menu hierarchy (Admin only)
     * Hiển thị đầy đủ cây menu để quản lý
     */
    @GetMapping("/hierarchy")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MenuResponse>> getMenuHierarchy() {
        List<MenuResponse> menus = menuService.getFullMenuHierarchy();
        return ResponseEntity.ok(menus);
    }

    /**
     * GET /api/menus/{id}
     * Lấy chi tiết menu theo ID (Admin only)
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> getMenuById(@PathVariable Long id) {
        MenuResponse menu = menuService.getMenuById(id);
        return ResponseEntity.ok(menu);
    }

    /**
     * POST /api/menus
     * Tạo menu mới (Admin only)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> createMenu(@Valid @RequestBody MenuRequest request) {
        MenuResponse menu = menuService.createMenu(request);
        return ResponseEntity.ok(menu);
    }

    /**
     * PUT /api/menus/{id}
     * Cập nhật menu (Admin only)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> updateMenu(
            @PathVariable Long id,
            @Valid @RequestBody MenuRequest request) {
        MenuResponse menu = menuService.updateMenu(id, request);
        return ResponseEntity.ok(menu);
    }

    /**
     * DELETE /api/menus/{id}
     * Xóa menu (Admin only)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteMenu(@PathVariable Long id) {
        menuService.deleteMenu(id);
        return ResponseEntity.noContent().build();
    }
}
