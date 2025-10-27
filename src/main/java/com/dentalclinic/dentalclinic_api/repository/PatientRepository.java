package com.dentalclinic.dentalclinic_api.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.dentalclinic.dentalclinic_api.entity.Patient;

/**
 * Repository for Patient entity operations.
 */
@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {

    /**
     * Find patients by phone number.
     */
    List<Patient> findByPhoneNumber(String phoneNumber);

    /**
     * Find patient by email.
     */
    Optional<Patient> findByEmail(String email);

    /**
     * Find all active patients.
     */
    List<Patient> findByActiveTrue();

    /**
     * Search patients by name (case-insensitive, partial match).
     */
    List<Patient> findByFullNameContainingIgnoreCase(String name);
}
