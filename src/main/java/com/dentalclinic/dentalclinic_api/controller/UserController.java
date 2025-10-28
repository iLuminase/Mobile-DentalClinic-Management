package com.dentalclinic.dentalclinic_api.controller;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.http.HttpStatus;
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

import com.dentalclinic.dentalclinic_api.dto.ChangePasswordRequest;
import com.dentalclinic.dentalclinic_api.dto.PasswordResponse;
import com.dentalclinic.dentalclinic_api.dto.UpdateStatusRequest;
import com.dentalclinic.dentalclinic_api.dto.UserRequest;
import com.dentalclinic.dentalclinic_api.dto.UserResponse;
import com.dentalclinic.dentalclinic_api.service.UserService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;


@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    // Lấy danh sách người dùng
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        List<UserResponse> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/doctors")
    @PreAuthorize("hasAnyRole('ADMIN', 'RECEPTIONIST')")
    public ResponseEntity<List<UserResponse>> getAllDoctors() {
        List<UserResponse> doctors = userService.getAllDoctors();
        return ResponseEntity.ok(doctors);
    }


    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        UserResponse user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }


    @GetMapping("/username/{username}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> getUserByUsername(@PathVariable String username) {
        UserResponse user = userService.getUserByUsername(username);
        return ResponseEntity.ok(user);
    }


    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody UserRequest request) {
        UserResponse user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }


    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UserRequest request) {
        UserResponse user = userService.updateUser(id, request);
        return ResponseEntity.ok(user);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(Map.of("message", "User deleted successfully"));
    }


    @PutMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> assignRoles(
            @PathVariable Long id,
            @RequestBody Set<String> roleNames) {
        UserResponse user = userService.assignRoles(id, roleNames);
        return ResponseEntity.ok(user);
    }

    // Cập nhật trạng thái user
    @PutMapping("{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> updateUserStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateStatusRequest request) {
        UserResponse user = userService.updateUserStatus(id, request.getActive());
        return ResponseEntity.ok(user);
    }

    /**
     * Đổi mật khẩu (User tự đổi)
     * Endpoint: PUT /api/users/change-password
     * Ai cũng có quyền đổi mật khẩu của chính mình
     */
    @PutMapping("/change-password")
    public ResponseEntity<PasswordResponse> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request) {
        String username = authentication.getName();
        log.info("User {} yeu cau doi mat khau", username);
        PasswordResponse response = userService.changePassword(username, request);
        
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    /**
     * Reset mật khẩu về mặc định (Admin only)
     * Endpoint: PUT /api/users/{id}/reset-password
     * Mật khẩu mặc định: password123
     */
    @PutMapping("/{id}/reset-password")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PasswordResponse> resetPassword(@PathVariable Long id) {
        log.info("Admin yeu cau reset mat khau cho user ID: {}", id);
        PasswordResponse response = userService.resetPasswordToDefault(id);
        return ResponseEntity.ok(response);
    }
}

