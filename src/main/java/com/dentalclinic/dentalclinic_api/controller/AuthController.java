package com.dentalclinic.dentalclinic_api.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.dentalclinic.dentalclinic_api.dto.AuthResponse;
import com.dentalclinic.dentalclinic_api.dto.LoginRequest;
import com.dentalclinic.dentalclinic_api.dto.RegisterRequest;
import com.dentalclinic.dentalclinic_api.service.AuthService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// API xác thực: đăng nhập, đăng ký, refresh token
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    // Đăng nhập
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Login failed for user: {}", request.getUsername(), e);
            throw new RuntimeException("Invalid username or password");
        }
    }

    // Đăng ký tài khoản mới (mặc định role VIEWER - chỉ xem)
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            log.error("Register failed for user: {}", request.getUsername(), e);
            throw e;
        } catch (Exception e) {
            log.error("Register failed for user: {}", request.getUsername(), e);
            throw new RuntimeException("Registration failed");
        }
    }

    // Làm mới token
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody Map<String, String> request) {
        try {
            String refreshToken = request.get("refreshToken");
            if (refreshToken == null || refreshToken.isEmpty()) {
                throw new RuntimeException("Refresh token is required");
            }
            
            AuthResponse response = authService.refreshToken(refreshToken);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Refresh token failed", e);
            throw new RuntimeException("Invalid refresh token");
        }
    }

    // Kiểm tra xác thực
    @GetMapping("/me")
    public ResponseEntity<Map<String, String>> getCurrentUser() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Xác thực thành công");
        return ResponseEntity.ok(response);
    }
}
