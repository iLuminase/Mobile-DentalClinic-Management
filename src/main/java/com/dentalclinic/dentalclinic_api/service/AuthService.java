package com.dentalclinic.dentalclinic_api.service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dentalclinic.dentalclinic_api.dto.AuthResponse;
import com.dentalclinic.dentalclinic_api.dto.LoginRequest;
import com.dentalclinic.dentalclinic_api.dto.RegisterRequest;
import com.dentalclinic.dentalclinic_api.entity.Role;
import com.dentalclinic.dentalclinic_api.entity.User;
import com.dentalclinic.dentalclinic_api.enums.RoleEnum;
import com.dentalclinic.dentalclinic_api.exception.AccountDisabledException;
import com.dentalclinic.dentalclinic_api.repository.RoleRepository;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;
import com.dentalclinic.dentalclinic_api.security.JwtService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// Service xử lý đăng nhập, đăng ký, refresh token
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;
    private final PasswordEncoder passwordEncoder;

    @Value("${jwt.expiration:86400000}")
    private Long jwtExpiration;

    // Đăng nhập: xác thực và tạo JWT token
    @Transactional
    public AuthResponse login(LoginRequest request) {
        log.info("Login attempt: {}", request.getUsername());

        // Kiểm tra tài khoản có tồn tại và có bị vô hiệu hóa không trước khi authenticate
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Tên đăng nhập hoặc mật khẩu không đúng"));

        if (!user.getActive()) {
            log.warn("Disabled account login attempt: {}", request.getUsername());
            throw new AccountDisabledException(
                user.getUsername(), 
                "Vui lòng liên hệ quản trị viên để được hỗ trợ."
            );
        }

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
        } catch (DisabledException e) {
            throw new AccountDisabledException(
                request.getUsername(), 
                "Vui lòng liên hệ quản trị viên để được hỗ trợ."
            );
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getUsername());

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        String accessToken = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        log.info("Login successful: {}", request.getUsername());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtExpiration / 1000)
                .user(AuthResponse.UserInfo.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .email(user.getEmail())
                        .fullName(user.getFullName())
                        .roles(user.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                        .build())
                .build();
    }

    // Làm mới access token
    public AuthResponse refreshToken(String refreshToken) {
        log.info("Refreshing token");

        String username = jwtService.extractUsername(refreshToken);
        
        // Kiểm tra tài khoản có bị vô hiệu hóa không trước khi refresh
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));

        if (!user.getActive()) {
            log.warn("Disabled account refresh token attempt: {}", username);
            throw new AccountDisabledException(
                username, 
                "Vui lòng liên hệ quản trị viên để được hỗ trợ."
            );
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(username);

        if (!jwtService.isTokenValid(refreshToken, userDetails)) {
            throw new RuntimeException("Refresh token không hợp lệ");
        }

        String newAccessToken = jwtService.generateToken(userDetails);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtExpiration / 1000)
                .user(AuthResponse.UserInfo.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .email(user.getEmail())
                        .fullName(user.getFullName())
                        .roles(user.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                        .build())
                .build();
    }

    // Đăng ký user mới (mặc định ROLE_PENDING_USER)
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Register attempt: {}", request.getUsername());

        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username đã tồn tại");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã được sử dụng");
        }

        // Use default role from enum: ROLE_PENDING_USER
        Role pendingUserRole = roleRepository.findByName(RoleEnum.getDefaultRole().getRoleName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy role mặc định: " + RoleEnum.getDefaultRole().getRoleName()));

        User newUser = new User();
        newUser.setUsername(request.getUsername());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setEmail(request.getEmail());
        newUser.setFullName(request.getFullName());
        newUser.setPhoneNumber(request.getPhoneNumber());
        newUser.setActive(true);

        Set<Role> roles = new HashSet<>();
        roles.add(pendingUserRole);
        newUser.setRoles(roles);

        userRepository.save(newUser);
        log.info("Register successful: {}", request.getUsername());

        UserDetails userDetails = userDetailsService.loadUserByUsername(newUser.getUsername());
        String accessToken = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(jwtExpiration / 1000)
                .user(AuthResponse.UserInfo.builder()
                        .id(newUser.getId())
                        .username(newUser.getUsername())
                        .email(newUser.getEmail())
                        .fullName(newUser.getFullName())
                        .roles(newUser.getRoles().stream().map(Role::getName).collect(Collectors.toSet()))
                        .build())
                .build();
    }
}
