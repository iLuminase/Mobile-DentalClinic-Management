package com.dentalclinic.dentalclinic_api.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dentalclinic.dentalclinic_api.dto.ChangePasswordRequest;
import com.dentalclinic.dentalclinic_api.dto.PasswordResponse;
import com.dentalclinic.dentalclinic_api.dto.UserRequest;
import com.dentalclinic.dentalclinic_api.dto.UserResponse;
import com.dentalclinic.dentalclinic_api.entity.Role;
import com.dentalclinic.dentalclinic_api.entity.User;
import com.dentalclinic.dentalclinic_api.enums.RoleEnum;
import com.dentalclinic.dentalclinic_api.repository.RoleRepository;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Service for user management operations.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Get all users.
     */
    public List<UserResponse> getAllUsers() {
        log.info("Lay tat ca nguoi dung");
        return userRepository.findAll().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get user by ID.
     */
    public UserResponse getUserById(Long id) {
        log.info("Lay nguoi dung theo ID: {}", id);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Khong tim thay nguoi dung voi ID: " + id));
        return convertToResponse(user);
    }

    /**
     * Get user by username.
     */
    public UserResponse getUserByUsername(String username) {
        log.info("Lay nguoi dung theo username: {}", username);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Khong tim thay nguoi dung: " + username));
        return convertToResponse(user);
    }

    /**
     * Get all doctors.
     */
    public List<UserResponse> getAllDoctors() {
        log.info("Lay tat ca bac si");
        return userRepository.findAllDoctors().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Create new user.
     */
    @Transactional
    public UserResponse createUser(UserRequest request) {
        log.info("Tao nguoi dung moi: {}", request.getUsername());

        // Validate unique constraints
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Ten dang nhap da ton tai: " + request.getUsername());
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email da duoc su dung: " + request.getEmail());
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setFullName(request.getFullName());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setAddress(request.getAddress());
        user.setActive(request.getActive());

        // Assign roles - if not provided, use default ROLE_PENDING_USER
        if (request.getRoleNames() != null && !request.getRoleNames().isEmpty()) {
            Set<Role> roles = new HashSet<>();
            for (String roleName : request.getRoleNames()) {
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new RuntimeException("Khong tim thay role: " + roleName));
                roles.add(role);
            }
            user.setRoles(roles);
        } else {
            // Default role: ROLE_PENDING_USER
            Role defaultRole = roleRepository.findByName(RoleEnum.getDefaultRole().getRoleName())
                    .orElseThrow(() -> new RuntimeException("Khong tim thay role mac dinh: " + RoleEnum.getDefaultRole().getRoleName()));
            Set<Role> roles = new HashSet<>();
            roles.add(defaultRole);
            user.setRoles(roles);
        }

        User savedUser = userRepository.save(user);
        log.info("Tao nguoi dung thanh cong: {}", savedUser.getUsername());

        return convertToResponse(savedUser);
    }

    /**
     * Update existing user.
     */
    @Transactional
    public UserResponse updateUser(Long id, UserRequest request) {
        log.info("Cap nhat nguoi dung ID: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Khong tim thay nguoi dung voi ID: " + id));

        // Check unique constraints if changed
        if (!user.getUsername().equals(request.getUsername()) &&
                userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Ten dang nhap da ton tai: " + request.getUsername());
        }
        if (!user.getEmail().equals(request.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email da duoc su dung: " + request.getEmail());
        }

        user.setUsername(request.getUsername());
        if (request.getPassword() != null && !request.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        user.setEmail(request.getEmail());
        user.setFullName(request.getFullName());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setAddress(request.getAddress());
        user.setActive(request.getActive());

        // Update roles if provided
        if (request.getRoleNames() != null) {
            Set<Role> roles = new HashSet<>();
            for (String roleName : request.getRoleNames()) {
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new RuntimeException("Khong tim thay role: " + roleName));
                roles.add(role);
            }
            user.setRoles(roles);
        }

        User updatedUser = userRepository.save(user);
        log.info("Cap nhat nguoi dung thanh cong: {}", updatedUser.getUsername());

        return convertToResponse(updatedUser);
    }

    /**
     * Delete user.
     */
    @Transactional
    public void deleteUser(Long id) {
        log.info("Xoa nguoi dung ID: {}", id);

        if (!userRepository.existsById(id)) {
            throw new RuntimeException("Khong tim thay nguoi dung voi ID: " + id);
        }

        userRepository.deleteById(id);
        log.info("Xoa nguoi dung thanh cong");
    }

    /**
     * Assign roles to user.
     */
    @Transactional
    public UserResponse assignRoles(Long userId, Set<String> roleNames) {
        log.info("Gan role cho nguoi dung ID: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Khong tim thay nguoi dung voi ID: " + userId));

        Set<Role> roles = new HashSet<>();
        for (String roleName : roleNames) {
            Role role = roleRepository.findByName(roleName)
                    .orElseThrow(() -> new RuntimeException("Khong tim thay role: " + roleName));
            roles.add(role);
        }

        user.setRoles(roles);
        User updatedUser = userRepository.save(user);
        log.info("Gan role thanh cong");

        return convertToResponse(updatedUser);
    }

    /**
     * Convert User entity to UserResponse DTO.
     */
    private UserResponse convertToResponse(User user) {
        // Tạo bản sao của roles để tránh ConcurrentModificationException
        List<String> roleNames = new ArrayList<>(user.getRoles()).stream()
                .map(Role::getName)
                .collect(Collectors.toList());

        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phoneNumber(user.getPhoneNumber())
                .dateOfBirth(user.getDateOfBirth())
                .address(user.getAddress())
                .roles(roleNames)
                .active(user.getActive())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .lastLoginAt(user.getLastLoginAt())
                .build();
    }

    public UserResponse updateUserStatus(Long id, Boolean isActive) {
        log.info("Cap nhat trang thai cho nguoi dung ID: {}", id);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Khong tim thay nguoi dung voi ID: " + id));
        user.setActive(isActive);
        User updatedUser = userRepository.save(user);
        return convertToResponse(updatedUser);
    }

    /**
     * Đổi mật khẩu (user tự đổi)
     * Yêu cầu: phải nhập đúng mật khẩu hiện tại
     */
    @Transactional
    public PasswordResponse changePassword(String username, ChangePasswordRequest request) {
        log.info("User {} dang thay doi mat khau", username);

        // Validate new password và confirm password match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            return new PasswordResponse(false, "Mat khau moi va xac nhan mat khau khong khop");
        }

        // Tìm user
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Khong tim thay user: " + username));

        // Verify mật khẩu hiện tại
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            return new PasswordResponse(false, "Mat khau hien tai khong dung");
        }

        // Kiểm tra mật khẩu mới không trùng với mật khẩu cũ
        if (passwordEncoder.matches(request.getNewPassword(), user.getPassword())) {
            return new PasswordResponse(false, "Mat khau moi khong duoc trung voi mat khau hien tai");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        log.info("Mat khau cua user {} da duoc thay doi thanh cong", username);
        return new PasswordResponse(true, "Doi mat khau thanh cong", username);
    }

    /**
     * Reset mật khẩu về mặc định (Admin only)
     * Mật khẩu mặc định: "password123"
     */
    @Transactional
    public PasswordResponse resetPasswordToDefault(Long userId) {
        log.info("Admin dang reset mat khau cho user ID: {}", userId);

        String defaultPassword = "password123";

        // Tìm user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Khong tim thay user voi ID: " + userId));

        // Reset password
        user.setPassword(passwordEncoder.encode(defaultPassword));
        userRepository.save(user);

        log.info("Mat khau cua user {} (ID: {}) da duoc reset ve mac dinh", user.getUsername(), userId);
        return new PasswordResponse(
            true, 
            "Reset mat khau thanh cong. Mat khau moi: " + defaultPassword, 
            user.getUsername(),
            defaultPassword
        );
    }
}

