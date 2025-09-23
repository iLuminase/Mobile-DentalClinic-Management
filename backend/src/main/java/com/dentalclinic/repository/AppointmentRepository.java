package com.dentalclinic.repository;

import com.dentalclinic.entity.Appointment;
import com.dentalclinic.entity.Customer;
import com.dentalclinic.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    
    List<Appointment> findByCustomer(Customer customer);
    
    List<Appointment> findByEmployee(Employee employee);
    
    List<Appointment> findByStatus(Appointment.AppointmentStatus status);
    
    @Query("SELECT a FROM Appointment a WHERE a.appointmentDateTime BETWEEN :startDate AND :endDate")
    List<Appointment> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                    @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM Appointment a WHERE a.employee = :employee AND a.appointmentDateTime BETWEEN :startDate AND :endDate")
    List<Appointment> findByEmployeeAndDateRange(@Param("employee") Employee employee,
                                               @Param("startDate") LocalDateTime startDate,
                                               @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM Appointment a WHERE a.customer = :customer AND a.appointmentDateTime BETWEEN :startDate AND :endDate")
    List<Appointment> findByCustomerAndDateRange(@Param("customer") Customer customer,
                                               @Param("startDate") LocalDateTime startDate,
                                               @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT a FROM Appointment a WHERE a.employee = :employee AND a.status = :status")
    List<Appointment> findByEmployeeAndStatus(@Param("employee") Employee employee, 
                                            @Param("status") Appointment.AppointmentStatus status);
    
    @Query("SELECT COUNT(a) FROM Appointment a WHERE a.employee = :employee AND " +
           "a.appointmentDateTime BETWEEN :startTime AND :endTime AND a.status != 'CANCELLED'")
    Long countConflictingAppointments(@Param("employee") Employee employee,
                                    @Param("startTime") LocalDateTime startTime,
                                    @Param("endTime") LocalDateTime endTime);
}