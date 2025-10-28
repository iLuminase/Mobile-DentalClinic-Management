package com.dentalclinic.dentalclinic_api.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dentalclinic.dentalclinic_api.dto.RoleResponse;
import com.dentalclinic.dentalclinic_api.entity.Role;
import com.dentalclinic.dentalclinic_api.repository.RoleRepository;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * Service quản lý Role.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RoleService {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;

    // Lấy tất cả vai trò
    @Transactional(readOnly = true)
    public List<RoleResponse> getAllRoles() {
        log.info("Lấy danh sách tất cả vai trò");
        return roleRepository.findAll().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    // Lấy vai trò theo ID
    @Transactional(readOnly = true)
    public RoleResponse getRoleById(Long id) {
        log.info("Lấy vai trò với ID: {}", id);
        Role role = roleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy vai trò với ID: " + id));
        return convertToResponse(role);
    }

    // Lấy tất cả vai trò đang hoạt động
    @Transactional(readOnly = true)
    public List<RoleResponse> getActiveRoles() {
        log.info("Lấy danh sách vai trò đang hoạt động");
        return roleRepository.findByActive(true).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    // Lấy tên tất cả vai trò (chỉ trả về List<String>)
    @Transactional(readOnly = true)
    public List<String> getAllRoleNames() {
        log.info("Lấy danh sách tên vai trò");
        return roleRepository.findAll().stream()
                .map(Role::getName)
                .collect(Collectors.toList());
    }

    // Lấy Map của roles (ID -> Tên) cho Frontend
    @Transactional(readOnly = true)
    public java.util.Map<Long, String> getRolesMap() {
        log.info("Lấy Map ID -> Tên vai trò");
        return roleRepository.findAll().stream()
                .collect(Collectors.toMap(
                    Role::getId,
                    Role::getName
                ));
    }

    // Convert Entity sang Response DTO
    private RoleResponse convertToResponse(Role role) {
        // Đếm số lượng users có role này
        long userCount = userRepository.findAll().stream()
                .filter(user -> user.getRoles().contains(role))
                .count();

        return RoleResponse.builder()
                .id(role.getId())
                .name(role.getName())
                .description(role.getDescription())
                .active(role.getActive())
                .userCount(userCount)
                .createdAt(role.getCreatedAt())
                .updatedAt(role.getUpdatedAt())
                .build();
    }
}
