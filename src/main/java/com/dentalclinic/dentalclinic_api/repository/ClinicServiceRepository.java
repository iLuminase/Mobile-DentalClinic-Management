package com.dentalclinic.dentalclinic_api.repository;

import com.dentalclinic.dentalclinic_api.model.ClinicService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClinicServiceRepository extends JpaRepository<ClinicService, Long> {
    // Bạn có thể thêm custom query nếu cần, ví dụ:
    // List<ClinicService> findByCategory(String category);
}
