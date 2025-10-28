package com.dentalclinic.dentalclinic_api.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dentalclinic.dentalclinic_api.entity.Appointment;
import com.dentalclinic.dentalclinic_api.entity.AppointmentStatus;
import com.dentalclinic.dentalclinic_api.entity.Patient;
import com.dentalclinic.dentalclinic_api.entity.User;

/**
 * Repository for Appointment entity operations.
 */
@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    /**
     * Find appointments by patient.
     */
    List<Appointment> findByPatient(Patient patient);

    /**
     * Find appointments by doctor.
     */
    List<Appointment> findByDoctor(User doctor);

    /**
     * Find appointments by status.
     */
    List<Appointment> findByStatus(AppointmentStatus status);

    /**
     * Find appointments by patient and status.
     */
    List<Appointment> findByPatientAndStatus(Patient patient, AppointmentStatus status);

    /**
     * Check if doctor has time conflict.
     * Returns appointments that overlap with the given time range.
     */
    @Query("SELECT a FROM Appointment a WHERE a.doctor = :doctor " +
           "AND a.status NOT IN ('CANCELLED', 'COMPLETED') " +
           "AND ((a.appointmentDateTime < :endTime AND " +
           "      FUNCTION('DATEADD', MINUTE, a.durationMinutes, a.appointmentDateTime) > :startTime) " +
           "OR (a.actualEndTime IS NOT NULL AND a.appointmentDateTime < :endTime AND a.actualEndTime > :startTime))")
    List<Appointment> findDoctorConflictingAppointments(
            @Param("doctor") User doctor,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime
    );

    /**
     * Find patient's active (not completed/cancelled) appointments.
     */
    @Query("SELECT a FROM Appointment a WHERE a.patient = :patient " +
           "AND a.status NOT IN ('COMPLETED', 'CANCELLED') " +
           "ORDER BY a.appointmentDateTime ASC")
    List<Appointment> findPatientActiveAppointments(@Param("patient") Patient patient);

    /**
     * Find appointments by doctor within date range.
     */
    @Query("SELECT a FROM Appointment a WHERE a.doctor = :doctor " +
           "AND a.appointmentDateTime BETWEEN :startDate AND :endDate " +
           "ORDER BY a.appointmentDateTime ASC")
    List<Appointment> findByDoctorAndDateRange(
            @Param("doctor") User doctor,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );

    /**
     * Find all appointments within date range.
     */
    @Query("SELECT a FROM Appointment a WHERE a.appointmentDateTime BETWEEN :startDate AND :endDate " +
           "ORDER BY a.appointmentDateTime ASC")
    List<Appointment> findByDateRange(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate
    );
}
