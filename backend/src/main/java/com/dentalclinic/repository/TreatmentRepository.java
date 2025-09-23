package com.dentalclinic.repository;

import com.dentalclinic.entity.Treatment;
import com.dentalclinic.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TreatmentRepository extends JpaRepository<Treatment, Long> {
    
    List<Treatment> findByAppointment(Appointment appointment);
    
    List<Treatment> findByStatus(Treatment.TreatmentStatus status);
    
    @Query("SELECT t FROM Treatment t WHERE t.treatmentName LIKE %:name%")
    List<Treatment> findByTreatmentNameContaining(@Param("name") String name);
    
    @Query("SELECT t FROM Treatment t WHERE t.appointment.customer.id = :customerId")
    List<Treatment> findByCustomerId(@Param("customerId") Long customerId);
    
    @Query("SELECT t FROM Treatment t WHERE t.appointment.employee.id = :employeeId")
    List<Treatment> findByEmployeeId(@Param("employeeId") Long employeeId);
}