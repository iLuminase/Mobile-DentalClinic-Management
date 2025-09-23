package com.dentalclinic.repository;

import com.dentalclinic.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    
    Optional<Employee> findByEmail(String email);
    
    List<Employee> findByRole(Employee.Role role);
    
    List<Employee> findByStatus(Employee.EmployeeStatus status);
    
    @Query("SELECT e FROM Employee e WHERE e.firstName LIKE %:name% OR e.lastName LIKE %:name%")
    List<Employee> findByNameContaining(@Param("name") String name);
    
    @Query("SELECT e FROM Employee e WHERE e.role = :role AND e.status = :status")
    List<Employee> findByRoleAndStatus(@Param("role") Employee.Role role, @Param("status") Employee.EmployeeStatus status);
    
    boolean existsByEmail(String email);
    
    boolean existsByLicenseNumber(String licenseNumber);
}