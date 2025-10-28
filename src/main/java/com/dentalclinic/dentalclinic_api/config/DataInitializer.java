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

// Khởi tạo dữ liệu mặc định khi ứng dụng chạy
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
            log.info("Khoi tao du lieu mac dinh...");

            // Tạo vai trò
            Role adminRole = createRoleIfNotExists("ROLE_ADMIN", "Quan tri vien he thong");
            Role doctorRole = createRoleIfNotExists("ROLE_DOCTOR", "Bac si nha khoa");
            Role receptionistRole = createRoleIfNotExists("ROLE_RECEPTIONIST", "Le tan");
            createRoleIfNotExists("ROLE_VIEWER", "Nguoi dung chi xem");
            createRoleIfNotExists("ROLE_PENDING_USER", "Nguoi dung cho duyet");

            // Tạo tài khoản admin
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
                log.info("Tao tai khoan admin: username=admin, password=admin123");
            }

            // Tạo tài khoản demo bác sĩ
            if (!userRepository.existsByUsername("doctor1")) {
                User doctor = new User();
                doctor.setUsername("doctor1");
                doctor.setPassword(passwordEncoder.encode("doctor123"));
                doctor.setEmail("doctor1@dentalclinic.com");
                doctor.setFullName("Bac si Nguyen Van A");
                doctor.setActive(true);

                Set<Role> roles = new HashSet<>();
                roles.add(doctorRole);
                doctor.setRoles(roles);

                userRepository.save(doctor);
                log.info("Tao tai khoan bac si: username=doctor1, password=doctor123");
            }

            // Tạo tài khoản demo lễ tân
            if (!userRepository.existsByUsername("receptionist1")) {
                User receptionist = new User();
                receptionist.setUsername("receptionist1");
                receptionist.setPassword(passwordEncoder.encode("receptionist123"));
                receptionist.setEmail("receptionist1@dentalclinic.com");
                receptionist.setFullName("Le tan Tran Thi B");
                receptionist.setActive(true);

                Set<Role> roles = new HashSet<>();
                roles.add(receptionistRole);
                receptionist.setRoles(roles);

                userRepository.save(receptionist);
                log.info("Tao tai khoan le tan: username=receptionist1, password=receptionist123");
            }

            // Tạo menu mặc định
            createDefaultMenus(adminRole, doctorRole, receptionistRole);

            log.info("Khoi tao du lieu hoan tat");
        };
    }

    private Role createRoleIfNotExists(String name, String description) {
        return roleRepository.findByName(name).orElseGet(() -> {
            Role role = new Role();
            role.setName(name);
            role.setDescription(description);
            role.setActive(true);
            Role savedRole = roleRepository.save(role);
            log.info("Tao vai tro: {}", name);
            return savedRole;
        });
    }

    private void createDefaultMenus(Role adminRole, Role doctorRole, Role receptionistRole) {
        if (menuRepository.count() > 0) {
            log.info("Menu da ton tai, bo qua khoi tao menu");
            return;
        }

        log.info("Tao menu mac dinh...");

        // Dashboard - Tất cả vai trò
        Menu dashboard = createMenu("dashboard", "Tổng quan", "/dashboard", "dashboard", 1, null,
                Set.of(adminRole, doctorRole, receptionistRole));

        // Quản lý người dùng - Chỉ admin
        Menu users = createMenu("users", "Quan ly nguoi dung", "/users", "people", 2, null,
                Set.of(adminRole));

        // Quản lý bệnh nhân - Admin, Lễ tân
        Menu patients = createMenu("patients", "Quan ly benh nhan", "/patients", "person", 3, null,
                Set.of(adminRole, receptionistRole));
        createMenu("patients-list", "Danh sach benh nhan", "/patients/list", "list", 1, patients,
                Set.of(adminRole, receptionistRole));
        createMenu("patients-add", "Them benh nhan", "/patients/add", "add", 2, patients,
                Set.of(adminRole, receptionistRole));

        // Quản lý lịch hẹn - Admin, Bác sĩ, Lễ tân
        Menu appointments = createMenu("appointments", "Quan ly lich hen", "/appointments", "calendar_today", 4, null,
                Set.of(adminRole, doctorRole, receptionistRole));
        createMenu("appointments-list", "Danh sach lich hen", "/appointments/list", "list", 1, appointments,
                Set.of(adminRole, doctorRole, receptionistRole));
        createMenu("appointments-add", "Dat lich moi", "/appointments/add", "add", 2, appointments,
                Set.of(adminRole, receptionistRole));

        // Hồ sơ bệnh án - Chỉ bác sĩ
        Menu medicalRecords = createMenu("medical-records", "Ho so benh an", "/medical-records", "description", 5, null,
                Set.of(adminRole, doctorRole));

        // Dịch vụ nha khoa - Admin, Lễ tân
        Menu services = createMenu("services", "Dich vu nha khoa", "/services", "medical_services", 6, null,
                Set.of(adminRole, receptionistRole));

        // Hóa đơn - Admin, Lễ tân
        Menu invoices = createMenu("invoices", "Hoa don", "/invoices", "receipt", 7, null,
                Set.of(adminRole, receptionistRole));

        // Báo cáo - Chỉ admin
        Menu reports = createMenu("reports", "Bao cao", "/reports", "assessment", 8, null,
                Set.of(adminRole));

        // Cài đặt - Chỉ admin
        Menu settings = createMenu("settings", "Cai dat", "/settings", "settings", 9, null,
                Set.of(adminRole));

        log.info("Tao {} menu mac dinh thanh cong", menuRepository.count());
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
