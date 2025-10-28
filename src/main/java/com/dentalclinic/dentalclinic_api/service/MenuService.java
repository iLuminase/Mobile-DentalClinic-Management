package com.dentalclinic.dentalclinic_api.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
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
        log.info("Get menu for user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));

        // Tạo bản sao của user roles để tránh ConcurrentModificationException
        Set<Role> userRoles = new HashSet<>(user.getRoles());
        
        // Lấy TẤT CẢ menu (kể cả submenu) mà user có quyền
        List<Menu> allMenus = menuRepository.findAllByRolesIn(userRoles);
        
        // Build tree: lọc ra menu cha, tìm children cho từng cha
        Map<Long, List<Menu>> menusByParentId = allMenus.stream()
                .filter(m -> m.getParent() != null)
                .collect(Collectors.groupingBy(m -> m.getParent().getId()));
        
        // Chỉ lấy menu cha (parent == null)
        List<Menu> parentMenus = allMenus.stream()
                .filter(m -> m.getParent() == null)
                .sorted(Comparator.comparing(Menu::getOrderIndex))
                .collect(Collectors.toList());

        // Convert sang DTO và gán children
        return parentMenus.stream()
                .map(menu -> convertToResponseWithChildren(menu, menusByParentId))
                .collect(Collectors.toList());
    }

    // Lấy tất cả menu (Admin)
    @Transactional(readOnly = true)
    public List<MenuResponse> getAllMenus() {
        log.info("Get all menus");
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
        log.info("Create new menu: {}", request.getName());

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
        log.info("Menu created: {}", savedMenu.getName());

        return convertToResponse(savedMenu);
    }

    // Cập nhật menu
    @Transactional
    public MenuResponse updateMenu(Long id, MenuRequest request) {
        log.info("Update menu ID: {}", id);

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
        log.info("Menu updated: {}", updatedMenu.getName());

        return convertToResponse(updatedMenu);
    }

    // Xóa menu
    @Transactional
    public void deleteMenu(Long id) {
        log.info("Delete menu ID: {}", id);

        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + id));

        // Soft delete
        menu.setActive(false);
        menuRepository.save(menu);

        log.info("Menu deleted: {}", menu.getName());
    }

    // Cập nhật roles cho menu
    @Transactional
    public MenuResponse updateMenuRoles(Long id, List<String> roleNames) {
        log.info("Update roles for menu ID: {}", id);

        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + id));

        // Tìm các roles theo tên
        Set<Role> roles = new HashSet<>();
        for (String roleName : roleNames) {
            Role role = roleRepository.findByName(roleName)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy role: " + roleName));
            roles.add(role);
        }

        menu.setRoles(roles);
        Menu updatedMenu = menuRepository.save(menu);

        log.info("Updated roles for menu: {}", menu.getName());
        return convertToResponse(updatedMenu);
    }

    // ========== NEW METHODS FOR MOBILE ==========

    /**
     * Lấy menu flat list (không có hierarchy) - hữu ích cho search và breadcrumb
     */
    @Transactional(readOnly = true)
    public List<MenuResponse> getMenuFlatByUsername(String username) {
        log.info("Get flat menu for user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));

        // Tạo bản sao của user roles để tránh ConcurrentModificationException
        Set<Role> userRoles = new HashSet<>(user.getRoles());
        List<Menu> allMenus = menuRepository.findAllByRolesIn(userRoles);

        // Convert sang DTO flat (không có children)
        return allMenus.stream()
                .sorted(Comparator.comparing(Menu::getOrderIndex))
                .map(this::convertToResponseEnhanced)
                .collect(Collectors.toList());
    }

    /**
     * Lấy breadcrumb path từ root đến menu cụ thể
     */
    @Transactional(readOnly = true)
    public List<MenuResponse> getBreadcrumbPath(Long menuId, String username) {
        log.info("Get breadcrumb for menu ID: {} of user: {}", menuId, username);

        // Verify user có quyền access menu này
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));

        Menu menu = menuRepository.findById(menuId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy menu với ID: " + menuId));

        // Check permission - Tạo bản sao để tránh ConcurrentModificationException
        Set<Role> userRoles = new HashSet<>(user.getRoles());
        Set<Role> menuRoles = new HashSet<>(menu.getRoles());
        boolean hasPermission = menuRoles.stream()
                .anyMatch(userRoles::contains);

        if (!hasPermission) {
            throw new RuntimeException("User không có quyền truy cập menu này");
        }

        // Build breadcrumb từ current menu lên root
        LinkedList<MenuResponse> breadcrumb = new LinkedList<>();
        Menu current = menu;

        while (current != null) {
            breadcrumb.addFirst(convertToResponseEnhanced(current));
            current = current.getParent();
        }

        return breadcrumb;
    }

    /**
     * Lấy thống kê menu của user
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getMenuStatistics(String username) {
        log.info("Lấy thống kê menu cho user: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user: " + username));

        // Tạo bản sao của user roles để tránh ConcurrentModificationException
        Set<Role> userRoles = new HashSet<>(user.getRoles());
        List<Menu> allMenus = menuRepository.findAllByRolesIn(userRoles);

        // Count parent menus
        long parentCount = allMenus.stream()
                .filter(m -> m.getParent() == null)
                .count();

        // Count child menus
        long childCount = allMenus.stream()
                .filter(m -> m.getParent() != null)
                .count();

        // Count by depth level
        Map<Integer, Long> byDepth = allMenus.stream()
                .collect(Collectors.groupingBy(
                        m -> getMenuDepth(m),
                        Collectors.counting()
                ));

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalMenus", allMenus.size());
        stats.put("parentMenus", parentCount);
        stats.put("childMenus", childCount);
        stats.put("byDepth", byDepth);
        stats.put("roles", userRoles.stream().map(Role::getName).collect(Collectors.toList()));

        return stats;
    }

    /**
     * Lấy toàn bộ menu hierarchy (Admin)
     * Sử dụng eager loading để tránh LazyInitializationException
     */
    @Transactional(readOnly = true)
    public List<MenuResponse> getFullMenuHierarchy() {
        log.info("Lấy toàn bộ menu hierarchy");

        // Eager load children và roles
        List<Menu> allMenus = menuRepository.findAllWithChildrenAndRoles();

        // Group by parentId
        Map<Long, List<Menu>> menusByParentId = allMenus.stream()
                .filter(m -> m.getParent() != null)
                .collect(Collectors.groupingBy(m -> m.getParent().getId()));

        // Get root menus
        List<Menu> rootMenus = allMenus.stream()
                .filter(m -> m.getParent() == null)
                .sorted(Comparator.comparing(Menu::getOrderIndex))
                .collect(Collectors.toList());

        // Build hierarchy with enhanced info
        return rootMenus.stream()
                .map(menu -> convertToResponseWithChildrenEnhanced(menu, menusByParentId, 0))
                .collect(Collectors.toList());
    }

    // ========== HELPER METHODS ==========

    /**
     * Calculate menu depth
     */
    private int getMenuDepth(Menu menu) {
        int depth = 0;
        Menu current = menu;
        while (current.getParent() != null) {
            depth++;
            current = current.getParent();
        }
        return depth;
    }

    /**
     * Convert to enhanced response with mobile-friendly fields
     * Xử lý an toàn Hibernate lazy loading
     */
    private MenuResponse convertToResponseEnhanced(Menu menu) {
        int depth = getMenuDepth(menu);
        
        // Xử lý children - kiểm tra null và khởi tạo collection an toàn
        boolean hasChildren = false;
        if (menu.getChildren() != null) {
            try {
                // Force initialize bằng cách gọi size()
                Set<Menu> children = menu.getChildren();
                children.size(); // Trigger lazy loading
                hasChildren = !children.isEmpty();
            } catch (Exception e) {
                log.warn("Không thể load children cho menu {}: {} - {}", 
                        menu.getId(), e.getClass().getSimpleName(), e.getMessage(), e);
                hasChildren = false;
            }
        }

        // Xử lý roles - tạo bản sao an toàn
        List<String> roleNames = new ArrayList<>();
        if (menu.getRoles() != null) {
            try {
                // Force initialize và stream
                Set<Role> roles = menu.getRoles();
                roles.size(); // Trigger lazy loading
                roleNames = roles.stream()
                        .map(Role::getName)
                        .collect(Collectors.toList());
            } catch (Exception e) {
                log.warn("Không thể load roles cho menu {}: {} - {}", 
                        menu.getId(), e.getClass().getSimpleName(), e.getMessage(), e);
                roleNames = new ArrayList<>();
            }
        }

        return MenuResponse.builder()
                .id(menu.getId())
                .name(menu.getName())
                .title(menu.getTitle())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .iconType("material") // Default icon type
                .orderIndex(menu.getOrderIndex())
                .parentId(menu.getParent() != null ? menu.getParent().getId() : null)
                .active(menu.getActive())
                .depth(depth)
                .hasChildren(hasChildren)
                .roles(roleNames)
                .canView(true) // Default permissions - có thể customize sau
                .canEdit(roleNames.contains("ROLE_ADMIN"))
                .canDelete(roleNames.contains("ROLE_ADMIN"))
                .target("_self") // Default target
                .external(false) // Default not external
                .componentName(convertToComponentName(menu.getName())) // Generate component name
                .tooltip(menu.getTitle()) // Use title as default tooltip
                .children(new ArrayList<>())
                .build();
    }

    /**
     * Convert to enhanced response with children
     */
    private MenuResponse convertToResponseWithChildrenEnhanced(
            Menu menu,
            Map<Long, List<Menu>> menusByParentId,
            int depth) {

        MenuResponse response = convertToResponseEnhanced(menu);
        response.setDepth(depth);

        // Get children from map
        List<Menu> children = menusByParentId.getOrDefault(menu.getId(), new ArrayList<>());
        if (!children.isEmpty()) {
            List<MenuResponse> childrenResponses = children.stream()
                    .sorted(Comparator.comparing(Menu::getOrderIndex))
                    .map(child -> convertToResponseWithChildrenEnhanced(child, menusByParentId, depth + 1))
                    .collect(Collectors.toList());
            response.setChildren(childrenResponses);
            response.setHasChildren(true);
        }

        return response;
    }

    /**
     * Convert menu name to Flutter component name
     * Example: "users" -> "UsersScreen", "appointments-list" -> "AppointmentsListScreen"
     */
    private String convertToComponentName(String menuName) {
        if (menuName == null || menuName.isEmpty()) {
            return "Screen";
        }

        String[] parts = menuName.split("-");
        StringBuilder componentName = new StringBuilder();

        for (String part : parts) {
            if (!part.isEmpty()) {
                componentName.append(Character.toUpperCase(part.charAt(0)))
                        .append(part.substring(1).toLowerCase());
            }
        }

        componentName.append("Screen");
        return componentName.toString();
    }

    // ========== EXISTING CONVERSION METHODS (keep for backward compatibility) ==========

    // Convert entity -> DTO
    private MenuResponse convertToResponse(Menu menu) {
        // Xử lý roles - tạo bản sao an toàn
        List<String> roleNames = new ArrayList<>();
        if (menu.getRoles() != null) {
            try {
                Set<Role> roles = menu.getRoles();
                roles.size(); // Trigger lazy loading
                roleNames = roles.stream()
                        .map(Role::getName)
                        .collect(Collectors.toList());
            } catch (Exception e) {
                log.warn("Không thể load roles cho menu {}: {} - {}", 
                        menu.getId(), e.getClass().getSimpleName(), e.getMessage(), e);
                roleNames = new ArrayList<>();
            }
        }

        MenuResponse response = MenuResponse.builder()
                .id(menu.getId())
                .name(menu.getName())
                .title(menu.getTitle())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .orderIndex(menu.getOrderIndex())
                .parentId(menu.getParent() != null ? menu.getParent().getId() : null)
                .active(menu.getActive())
                .roles(roleNames) // SET ROLES
                .children(new ArrayList<>())
                .build();

        // Recursively load children - dùng try-catch tránh ConcurrentModificationException
        try {
            Set<Menu> childrenSet = menu.getChildren();
            if (childrenSet != null && !childrenSet.isEmpty()) {
                // Copy sang List mới để tránh ConcurrentModificationException
                List<Menu> childrenList = new ArrayList<>(childrenSet);
                List<MenuResponse> children = childrenList.stream()
                        .filter(Menu::getActive)
                        .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                        .map(this::convertToResponse)
                        .collect(Collectors.toList());
                response.setChildren(children);
            }
        } catch (Exception e) {
            log.warn("Không thể load children cho menu {}: {}", menu.getName(), e.getMessage());
            response.setChildren(new ArrayList<>());
        }

        return response;
    }

    // Convert entity -> DTO với children từ Map (tránh N+1 query)
    private MenuResponse convertToResponseWithChildren(Menu menu, Map<Long, List<Menu>> menusByParentId) {
        // Xử lý roles - tạo bản sao an toàn
        List<String> roleNames = new ArrayList<>();
        if (menu.getRoles() != null) {
            try {
                Set<Role> roles = menu.getRoles();
                roles.size(); // Trigger lazy loading
                roleNames = roles.stream()
                        .map(Role::getName)
                        .collect(Collectors.toList());
            } catch (Exception e) {
                log.warn("Không thể load roles cho menu {}: {} - {}", 
                        menu.getId(), e.getClass().getSimpleName(), e.getMessage(), e);
                roleNames = new ArrayList<>();
            }
        }

        MenuResponse response = MenuResponse.builder()
                .id(menu.getId())
                .name(menu.getName())
                .title(menu.getTitle())
                .path(menu.getPath())
                .icon(menu.getIcon())
                .orderIndex(menu.getOrderIndex())
                .parentId(menu.getParent() != null ? menu.getParent().getId() : null)
                .active(menu.getActive())
                .roles(roleNames) // SET ROLES
                .children(new ArrayList<>())
                .build();

        // Lấy children từ Map (đã được group sẵn)
        List<Menu> children = menusByParentId.getOrDefault(menu.getId(), new ArrayList<>());
        if (!children.isEmpty()) {
            List<MenuResponse> childrenResponses = children.stream()
                    .filter(Menu::getActive)
                    .sorted(Comparator.comparing(Menu::getOrderIndex))
                    .map(child -> convertToResponseWithChildren(child, menusByParentId)) // Recursive cho multilevel
                    .collect(Collectors.toList());
            response.setChildren(childrenResponses);
        }

        return response;
    }
}
