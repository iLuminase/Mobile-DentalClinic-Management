package com.dentalclinic.dentalclinic_api.config;

import java.util.HashSet;
import java.util.Set;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.dentalclinic.dentalclinic_api.entity.Menu;
import com.dentalclinic.dentalclinic_api.entity.Role;
import com.dentalclinic.dentalclinic_api.entity.User;
import com.dentalclinic.dentalclinic_api.repository.MenuRepository;
import com.dentalclinic.dentalclinic_api.repository.RoleRepository;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// Initialize default data when application starts
@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final MenuRepository menuRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initializeData() {
        return args -> {
            log.info("Initializing default data...");

            // Create roles
            Role adminRole = createRoleIfNotExists("ROLE_ADMIN", "Quản trị viên hệ thống");
            Role doctorRole = createRoleIfNotExists("ROLE_DOCTOR", "Bác sĩ nha khoa");
            Role receptionistRole = createRoleIfNotExists("ROLE_RECEPTIONIST", "Lễ tân");
            createRoleIfNotExists("ROLE_VIEWER", "Người dùng chỉ xem");
            createRoleIfNotExists("ROLE_PENDING_USER", "Người dùng chờ duyệt");

            // Create admin account
            if (!userRepository.existsByUsername("admin")) {
                User admin = new User();
                admin.setUsername("admin");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setEmail("admin@dentalclinic.com");
                admin.setFullName("Administrator");
                admin.setActive(true);
                
                Set<Role> roles = new HashSet<>();
                roles.add(adminRole);
                admin.setRoles(roles);
                
                userRepository.save(admin);
                log.info("Created admin user: username=admin, password=admin123");
            }

            // Create demo doctor account
            if (!userRepository.existsByUsername("doctor1")) {
                User doctor = new User();
                doctor.setUsername("doctor1");
                doctor.setPassword(passwordEncoder.encode("doctor123"));
                doctor.setEmail("doctor1@dentalclinic.com");
                doctor.setFullName("Bác sĩ Nguyễn Văn A");
                doctor.setActive(true);
                
                Set<Role> roles = new HashSet<>();
                roles.add(doctorRole);
                doctor.setRoles(roles);
                
                userRepository.save(doctor);
                log.info("Created doctor user: username=doctor1, password=doctor123");
            }

            // Create demo receptionist account
            if (!userRepository.existsByUsername("receptionist1")) {
                User receptionist = new User();
                receptionist.setUsername("receptionist1");
                receptionist.setPassword(passwordEncoder.encode("receptionist123"));
                receptionist.setEmail("receptionist1@dentalclinic.com");
                receptionist.setFullName("Lễ tân Trần Thị B");
                receptionist.setActive(true);
                
                Set<Role> roles = new HashSet<>();
                roles.add(receptionistRole);
                receptionist.setRoles(roles);
                
                userRepository.save(receptionist);
                log.info("Created receptionist user: username=receptionist1, password=receptionist123");
            }

            // Create default menus
            createDefaultMenus(adminRole, doctorRole, receptionistRole);

            log.info("Data initialization completed successfully");
        };
    }

    private Role createRoleIfNotExists(String name, String description) {
        return roleRepository.findByName(name).orElseGet(() -> {
            Role role = new Role();
            role.setName(name);
            role.setDescription(description);
            role.setActive(true);
            Role savedRole = roleRepository.save(role);
            log.info("Created role: {}", name);
            return savedRole;
        });
    }

    private void createDefaultMenus(Role adminRole, Role doctorRole, Role receptionistRole) {
        if (menuRepository.count() > 0) {
            log.info("Menus already exist, skipping menu initialization");
            return;
        }

        log.info("Creating default menus...");

        // Dashboard - All roles
        Menu dashboard = createMenu("dashboard", "Tổng quan", "/dashboard", "dashboard", 1, null,
                Set.of(adminRole, doctorRole, receptionistRole));

        // Users Management - Admin only
        Menu users = createMenu("users", "Quản lý người dùng", "/users", "people", 2, null,
                Set.of(adminRole));

        // Patients Management - Admin, Receptionist
        Menu patients = createMenu("patients", "Quản lý bệnh nhân", "/patients", "person", 3, null,
                Set.of(adminRole, receptionistRole));
        createMenu("patients-list", "Danh sách bệnh nhân", "/patients/list", "list", 1, patients,
                Set.of(adminRole, receptionistRole));
        createMenu("patients-add", "Thêm bệnh nhân", "/patients/add", "add", 2, patients,
                Set.of(adminRole, receptionistRole));

        // Appointments - Admin, Doctor, Receptionist
        Menu appointments = createMenu("appointments", "Quản lý lịch hẹn", "/appointments", "calendar_today", 4, null,
                Set.of(adminRole, doctorRole, receptionistRole));
        createMenu("appointments-list", "Danh sách lịch hẹn", "/appointments/list", "list", 1, appointments,
                Set.of(adminRole, doctorRole, receptionistRole));
        createMenu("appointments-add", "Đặt lịch mới", "/appointments/add", "add", 2, appointments,
                Set.of(adminRole, receptionistRole));

        // Medical Records - Doctor only
        Menu medicalRecords = createMenu("medical-records", "Hồ sơ bệnh án", "/medical-records", "description", 5, null,
                Set.of(adminRole, doctorRole));

        // Services - Admin, Receptionist
        Menu services = createMenu("services", "Dịch vụ nha khoa", "/services", "medical_services", 6, null,
                Set.of(adminRole, receptionistRole));

        // Invoices - Admin, Receptionist
        Menu invoices = createMenu("invoices", "Hóa đơn", "/invoices", "receipt", 7, null,
                Set.of(adminRole, receptionistRole));

        // Reports - Admin only
        Menu reports = createMenu("reports", "Báo cáo", "/reports", "assessment", 8, null,
                Set.of(adminRole));

        // Settings - Admin only
        Menu settings = createMenu("settings", "Cài đặt", "/settings", "settings", 9, null,
                Set.of(adminRole));

        log.info("Created {} default menus successfully", menuRepository.count());
    }

    private Menu createMenu(String name, String title, String path, String icon, int order, 
                           Menu parent, Set<Role> roles) {
        Menu menu = new Menu();
        menu.setName(name);
        menu.setTitle(title);
        menu.setPath(path);
        menu.setIcon(icon);
        menu.setOrderIndex(order);
        menu.setParent(parent);
        menu.setRoles(roles);
        menu.setActive(true);
        return menuRepository.save(menu);
    }
}
