package com.dentalclinic.service;

import com.dentalclinic.dto.EmployeeCreateDTO;
import com.dentalclinic.dto.EmployeeDTO;
import com.dentalclinic.entity.Employee;
import com.dentalclinic.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class EmployeeService {

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public List<EmployeeDTO> getAllEmployees() {
        return employeeRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Optional<EmployeeDTO> getEmployeeById(Long id) {
        return employeeRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<EmployeeDTO> getEmployeeByEmail(String email) {
        return employeeRepository.findByEmail(email)
                .map(this::convertToDTO);
    }

    public List<EmployeeDTO> getEmployeesByRole(Employee.Role role) {
        return employeeRepository.findByRole(role).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<EmployeeDTO> searchEmployeesByName(String name) {
        return employeeRepository.findByNameContaining(name).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public EmployeeDTO createEmployee(EmployeeCreateDTO createDTO) {
        if (employeeRepository.existsByEmail(createDTO.getEmail())) {
            throw new RuntimeException("Employee with email " + createDTO.getEmail() + " already exists");
        }

        Employee employee = new Employee();
        employee.setFirstName(createDTO.getFirstName());
        employee.setLastName(createDTO.getLastName());
        employee.setEmail(createDTO.getEmail());
        employee.setPassword(passwordEncoder.encode(createDTO.getPassword()));
        employee.setPhoneNumber(createDTO.getPhoneNumber());
        employee.setRole(Employee.Role.valueOf(createDTO.getRole().toUpperCase()));
        employee.setSpecialization(createDTO.getSpecialization());
        employee.setLicenseNumber(createDTO.getLicenseNumber());
        employee.setStatus(Employee.EmployeeStatus.ACTIVE);

        Employee savedEmployee = employeeRepository.save(employee);
        return convertToDTO(savedEmployee);
    }

    public EmployeeDTO updateEmployee(Long id, EmployeeDTO employeeDTO) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        employee.setFirstName(employeeDTO.getFirstName());
        employee.setLastName(employeeDTO.getLastName());
        employee.setEmail(employeeDTO.getEmail());
        employee.setPhoneNumber(employeeDTO.getPhoneNumber());
        employee.setRole(employeeDTO.getRole());
        employee.setSpecialization(employeeDTO.getSpecialization());
        employee.setLicenseNumber(employeeDTO.getLicenseNumber());

        if (employeeDTO.getStatus() != null) {
            employee.setStatus(employeeDTO.getStatus());
        }

        Employee savedEmployee = employeeRepository.save(employee);
        return convertToDTO(savedEmployee);
    }

    public void deleteEmployee(Long id) {
        if (!employeeRepository.existsById(id)) {
            throw new RuntimeException("Employee not found with id: " + id);
        }
        employeeRepository.deleteById(id);
    }

    public EmployeeDTO updateEmployeeStatus(Long id, Employee.EmployeeStatus status) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        employee.setStatus(status);
        Employee savedEmployee = employeeRepository.save(employee);
        return convertToDTO(savedEmployee);
    }

    private EmployeeDTO convertToDTO(Employee employee) {
        EmployeeDTO dto = new EmployeeDTO();
        dto.setId(employee.getId());
        dto.setFirstName(employee.getFirstName());
        dto.setLastName(employee.getLastName());
        dto.setEmail(employee.getEmail());
        dto.setPhoneNumber(employee.getPhoneNumber());
        dto.setRole(employee.getRole());
        dto.setStatus(employee.getStatus());
        dto.setSpecialization(employee.getSpecialization());
        dto.setLicenseNumber(employee.getLicenseNumber());
        return dto;
    }
}