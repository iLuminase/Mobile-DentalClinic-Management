package com.dentalclinic.service;

import com.dentalclinic.dto.AppointmentDTO;
import com.dentalclinic.entity.Appointment;
import com.dentalclinic.entity.Customer;
import com.dentalclinic.entity.Employee;
import com.dentalclinic.repository.AppointmentRepository;
import com.dentalclinic.repository.CustomerRepository;
import com.dentalclinic.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class AppointmentService {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private EmployeeRepository employeeRepository;

    public List<AppointmentDTO> getAllAppointments() {
        return appointmentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Optional<AppointmentDTO> getAppointmentById(Long id) {
        return appointmentRepository.findById(id)
                .map(this::convertToDTO);
    }

    public List<AppointmentDTO> getAppointmentsByCustomer(Long customerId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found with id: " + customerId));
        
        return appointmentRepository.findByCustomer(customer).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AppointmentDTO> getAppointmentsByEmployee(Long employeeId) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + employeeId));
        
        return appointmentRepository.findByEmployee(employee).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AppointmentDTO> getAppointmentsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return appointmentRepository.findByDateRange(startDate, endDate).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AppointmentDTO createAppointment(AppointmentDTO appointmentDTO) {
        Customer customer = customerRepository.findById(appointmentDTO.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Customer not found with id: " + appointmentDTO.getCustomerId()));

        Employee employee = employeeRepository.findById(appointmentDTO.getEmployeeId())
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + appointmentDTO.getEmployeeId()));

        // Check for conflicting appointments
        LocalDateTime startTime = appointmentDTO.getAppointmentDateTime();
        LocalDateTime endTime = startTime.plusMinutes(appointmentDTO.getDurationMinutes());
        
        Long conflictCount = appointmentRepository.countConflictingAppointments(employee, startTime, endTime);
        if (conflictCount > 0) {
            throw new RuntimeException("Employee has conflicting appointment during this time slot");
        }

        Appointment appointment = new Appointment();
        appointment.setCustomer(customer);
        appointment.setEmployee(employee);
        appointment.setAppointmentDateTime(appointmentDTO.getAppointmentDateTime());
        appointment.setDurationMinutes(appointmentDTO.getDurationMinutes());
        appointment.setServiceType(appointmentDTO.getServiceType());
        appointment.setDescription(appointmentDTO.getDescription());
        appointment.setCost(appointmentDTO.getCost());
        appointment.setStatus(Appointment.AppointmentStatus.SCHEDULED);

        Appointment savedAppointment = appointmentRepository.save(appointment);
        return convertToDTO(savedAppointment);
    }

    public AppointmentDTO updateAppointment(Long id, AppointmentDTO appointmentDTO) {
        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Appointment not found with id: " + id));

        if (appointmentDTO.getCustomerId() != null) {
            Customer customer = customerRepository.findById(appointmentDTO.getCustomerId())
                    .orElseThrow(() -> new RuntimeException("Customer not found with id: " + appointmentDTO.getCustomerId()));
            appointment.setCustomer(customer);
        }

        if (appointmentDTO.getEmployeeId() != null) {
            Employee employee = employeeRepository.findById(appointmentDTO.getEmployeeId())
                    .orElseThrow(() -> new RuntimeException("Employee not found with id: " + appointmentDTO.getEmployeeId()));
            appointment.setEmployee(employee);
        }

        if (appointmentDTO.getAppointmentDateTime() != null) {
            appointment.setAppointmentDateTime(appointmentDTO.getAppointmentDateTime());
        }

        if (appointmentDTO.getDurationMinutes() != null) {
            appointment.setDurationMinutes(appointmentDTO.getDurationMinutes());
        }

        if (appointmentDTO.getServiceType() != null) {
            appointment.setServiceType(appointmentDTO.getServiceType());
        }

        if (appointmentDTO.getDescription() != null) {
            appointment.setDescription(appointmentDTO.getDescription());
        }

        if (appointmentDTO.getNotes() != null) {
            appointment.setNotes(appointmentDTO.getNotes());
        }

        if (appointmentDTO.getCost() != null) {
            appointment.setCost(appointmentDTO.getCost());
        }

        if (appointmentDTO.getStatus() != null) {
            appointment.setStatus(appointmentDTO.getStatus());
        }

        Appointment savedAppointment = appointmentRepository.save(appointment);
        return convertToDTO(savedAppointment);
    }

    public AppointmentDTO updateAppointmentStatus(Long id, Appointment.AppointmentStatus status) {
        Appointment appointment = appointmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Appointment not found with id: " + id));

        appointment.setStatus(status);
        Appointment savedAppointment = appointmentRepository.save(appointment);
        return convertToDTO(savedAppointment);
    }

    public void deleteAppointment(Long id) {
        if (!appointmentRepository.existsById(id)) {
            throw new RuntimeException("Appointment not found with id: " + id);
        }
        appointmentRepository.deleteById(id);
    }

    private AppointmentDTO convertToDTO(Appointment appointment) {
        AppointmentDTO dto = new AppointmentDTO();
        dto.setId(appointment.getId());
        dto.setCustomerId(appointment.getCustomer().getId());
        dto.setEmployeeId(appointment.getEmployee().getId());
        dto.setCustomerName(appointment.getCustomer().getFirstName() + " " + appointment.getCustomer().getLastName());
        dto.setEmployeeName(appointment.getEmployee().getFirstName() + " " + appointment.getEmployee().getLastName());
        dto.setAppointmentDateTime(appointment.getAppointmentDateTime());
        dto.setDurationMinutes(appointment.getDurationMinutes());
        dto.setStatus(appointment.getStatus());
        dto.setServiceType(appointment.getServiceType());
        dto.setDescription(appointment.getDescription());
        dto.setNotes(appointment.getNotes());
        dto.setCost(appointment.getCost());
        return dto;
    }
}