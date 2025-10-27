package com.dentalclinic.dentalclinic_api.controller;

import java.util.List;

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

    // Lấy menu của user hiện tại
    @GetMapping("/me")
    public ResponseEntity<List<MenuResponse>> getMyMenus(Authentication authentication) {
        String username = authentication.getName();
        List<MenuResponse> menus = menuService.getMenuByUsername(username);
        return ResponseEntity.ok(menus);
    }

    // Lấy tất cả menu (Admin only)
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MenuResponse>> getAllMenus() {
        List<MenuResponse> menus = menuService.getAllMenus();
        return ResponseEntity.ok(menus);
    }

    // Lấy menu theo ID (Admin only)
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> getMenuById(@PathVariable Long id) {
        MenuResponse menu = menuService.getMenuById(id);
        return ResponseEntity.ok(menu);
    }

    // Tạo menu mới (Admin only)
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> createMenu(@Valid @RequestBody MenuRequest request) {
        MenuResponse menu = menuService.createMenu(request);
        return ResponseEntity.ok(menu);
    }

    // Cập nhật menu (Admin only)
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MenuResponse> updateMenu(
            @PathVariable Long id,
            @Valid @RequestBody MenuRequest request) {
        MenuResponse menu = menuService.updateMenu(id, request);
        return ResponseEntity.ok(menu);
    }

    // Xóa menu (Admin only)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteMenu(@PathVariable Long id) {
        menuService.deleteMenu(id);
        return ResponseEntity.noContent().build();
    }
}
