package com.dentalclinic.dentalclinic_api.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dentalclinic.dentalclinic_api.entity.User;

/**
 * Repository for User entity operations.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Find user by username.
     */
    Optional<User> findByUsername(String username);

    /**
     * Find user by email.
     */
    Optional<User> findByEmail(String email);

    /**
     * Check if username exists.
     */
    boolean existsByUsername(String username);

    /**
     * Check if email exists.
     */
    boolean existsByEmail(String email);

    /**
     * Find all active users.
     */
    List<User> findByActiveTrue();

    /**
     * Find users by role name.
     */
    @Query("SELECT u FROM User u JOIN u.roles r WHERE r.name = :roleName AND u.active = true")
    List<User> findByRoleName(@Param("roleName") String roleName);

    /**
     * Find all doctors (users with ROLE_DOCTOR).
     */
    @Query("SELECT u FROM User u JOIN u.roles r WHERE r.name = 'ROLE_DOCTOR' AND u.active = true")
    List<User> findAllDoctors();
}
