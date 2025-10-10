package com.dentalclinic.dentalclinic_api.repository;

import com.dentalclinic.dentalclinic_api.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    // Có thể thêm custom query sau, ví dụ:
    // Optional<Product> findByName(String name);
}
