package com.dentalclinic.repository;

import com.dentalclinic.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    
    Optional<Customer> findByEmail(String email);
    
    @Query("SELECT c FROM Customer c WHERE c.firstName LIKE %:name% OR c.lastName LIKE %:name%")
    List<Customer> findByNameContaining(@Param("name") String name);
    
    List<Customer> findByPhoneNumber(String phoneNumber);
    
    @Query("SELECT c FROM Customer c WHERE c.email LIKE %:email%")
    List<Customer> findByEmailContaining(@Param("email") String email);
    
    boolean existsByEmail(String email);
    
    boolean existsByPhoneNumber(String phoneNumber);
}