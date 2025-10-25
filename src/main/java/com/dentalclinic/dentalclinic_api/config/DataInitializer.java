package com.dentalclinic.dentalclinic_api.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.dentalclinic.dentalclinic_api.model.User;
import com.dentalclinic.dentalclinic_api.repository.UserRepository;


@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Check if users already exist to avoid duplicates
        if (userRepository.count() == 0) {
            createDefaultUsers();
        }
    }

    private void createDefaultUsers() {
        // Create admin user
        User admin = new User();
        admin.setUsername("admin");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setFullName("Administrator");
        admin.setActive(true);
        userRepository.save(admin);

        // Create doctor user
        User doctor = new User();
        doctor.setUsername("doctor1");
        doctor.setPassword(passwordEncoder.encode("doctor123"));
        doctor.setFullName("Dr. Nguyen Van A");
        doctor.setActive(true);
        userRepository.save(doctor);

        // Create receptionist user
        User receptionist = new User();
        receptionist.setUsername("receptionist");
        receptionist.setPassword(passwordEncoder.encode("reception123"));
        receptionist.setFullName("Le Thi B");
        receptionist.setActive(true);
        userRepository.save(receptionist);

        System.out.println("=== DEFAULT USERS CREATED ===");
        System.out.println("Admin: username=admin, password=admin123");
        System.out.println("Doctor: username=doctor1, password=doctor123");
        System.out.println("Receptionist: username=receptionist, password=reception123");
        System.out.println("===============================");
    }
}
