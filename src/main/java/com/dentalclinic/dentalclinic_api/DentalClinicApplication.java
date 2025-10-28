package com.dentalclinic.dentalclinic_api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Ứng dụng quản lý phòng khám nha khoa
@SpringBootApplication
public class DentalClinicApplication {
    public static void main(String[] args) {
        // Thiết lập UTF-8 cho console
        System.setProperty("file.encoding", "UTF-8");
        System.setProperty("console.encoding", "UTF-8");
        
        SpringApplication.run(DentalClinicApplication.class, args);
    }
}
