package com.dentalclinic.dentalclinic_api.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.dentalclinic.dentalclinic_api.dto.MenuRequest;
import com.dentalclinic.dentalclinic_api.dto.MenuResponse;
import com.dentalclinic.dentalclinic_api.entity.Menu;
import com.dentalclinic.dentalclinic_api.entity.Role;
import com.dentalclinic.dentalclinic_api.entity.User;
import com.dentalclinic.dentalclinic_api.repository.MenuRepository;
import com.dentalclinic.dentalclinic_api.repository.RoleRepository;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// Service quản lý menu và phân quyền
@Service
@RequiredArgsConstructor
@Slf4j
public class MenuService {

    private final MenuRepository menuRepository;
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;

    // Lấy menu theo username
    @Transactional(readOnly = true)
    public List<MenuResponse> getMenuByUsername(String username) {
        log.info("Lấy menu cho user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));

        Set<Role> userRoles = user.getRoles();
        List<Menu> menus = menuRepository.findByRolesInAndParentIsNull(userRoles);

        return menus.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    // Lấy tất cả menu (Admin)
    @Transactional(readOnly = true)
    public List<MenuResponse> getAllMenus() {
        log.info("Lấy tất cả menu");
        List<Menu> menus = menuRepository.findByParentIsNullAndActiveTrueOrderByOrderIndex();
        return menus.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    // Lấy menu theo ID
    @Transactional(readOnly = true)
    public MenuResponse getMenuById(Long id) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + id));
        return convertToResponse(menu);
    }

    // Tạo menu mới
    @Transactional
    public MenuResponse createMenu(MenuRequest request) {
        log.info("Tạo menu mới: {}", request.getName());

        if (menuRepository.existsByName(request.getName())) {
            throw new RuntimeException("Menu với tên '" + request.getName() + "' đã tồn tại");
        }

        Menu menu = new Menu();
        menu.setName(request.getName());
        menu.setTitle(request.getTitle());
        menu.setPath(request.getPath());
        menu.setIcon(request.getIcon());
        menu.setOrderIndex(request.getOrderIndex());
        menu.setActive(request.getActive() != null ? request.getActive() : true);

        // Set parent nếu có
        if (request.getParentId() != null) {
            Menu parent = menuRepository.findById(request.getParentId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy menu cha với ID: " + request.getParentId()));
            menu.setParent(parent);
        }

        // Gán roles
        if (request.getRoleNames() != null && !request.getRoleNames().isEmpty()) {
            Set<Role> roles = new HashSet<>();
            for (String roleName : request.getRoleNames()) {
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy role: " + roleName));
                roles.add(role);
            }
            menu.setRoles(roles);
        }

        Menu savedMenu = menuRepository.save(menu);
        log.info("Đã tạo menu: {}", savedMenu.getName());

        return convertToResponse(savedMenu);
    }

    // Cập nhật menu
    @Transactional
    public MenuResponse updateMenu(Long id, MenuRequest request) {
        log.info("Cập nhật menu ID: {}", id);

        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + id));

        menu.setName(request.getName());
        menu.setTitle(request.getTitle());
        menu.setPath(request.getPath());
        menu.setIcon(request.getIcon());
        menu.setOrderIndex(request.getOrderIndex());
        
        if (request.getActive() != null) {
            menu.setActive(request.getActive());
        }

        // Update parent
        if (request.getParentId() != null) {
            Menu parent = menuRepository.findById(request.getParentId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy menu cha với ID: " + request.getParentId()));
            menu.setParent(parent);
        } else {
            menu.setParent(null);
        }

        // Update roles
        if (request.getRoleNames() != null) {
            Set<Role> roles = new HashSet<>();
            for (String roleName : request.getRoleNames()) {
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy role: " + roleName));
                roles.add(role);
            }
            menu.setRoles(roles);
        }

        Menu updatedMenu = menuRepository.save(menu);
        log.info("Đã cập nhật menu: {}", updatedMenu.getName());

        return convertToResponse(updatedMenu);
    }

    // Xóa menu
    @Transactional
    public void deleteMenu(Long id) {
        log.info("Xóa menu ID: {}", id);

        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + id));

        // Soft delete
        menu.setActive(false);
        menuRepository.save(menu);

        log.info("Đã xóa menu: {}", menu.getName());
    }

    // Convert entity -> DTO
    private MenuResponse convertToResponse(Menu menu) {
        MenuResponse response = MenuResponse.builder()
                .id(menu.getId())
                .name(menu.getName())
                .title(menu.getTitle())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .orderIndex(menu.getOrderIndex())
                .parentId(menu.getParent() != null ? menu.getParent().getId() : null)
                .active(menu.getActive())
                .children(new ArrayList<>())
                .build();

        // Recursively load children
        if (menu.getChildren() != null && !menu.getChildren().isEmpty()) {
            List<MenuResponse> children = menu.getChildren().stream()
                    .filter(Menu::getActive)
                    .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                    .map(this::convertToResponse)
                    .collect(Collectors.toList());
            response.setChildren(children);
        }

        return response;
    }
}
