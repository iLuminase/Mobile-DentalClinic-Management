package com.dentalclinic.service;

import com.dentalclinic.dto.CustomerDTO;
import com.dentalclinic.entity.Customer;
import com.dentalclinic.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

    public List<CustomerDTO> getAllCustomers() {
        return customerRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Optional<CustomerDTO> getCustomerById(Long id) {
        return customerRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<CustomerDTO> getCustomerByEmail(String email) {
        return customerRepository.findByEmail(email)
                .map(this::convertToDTO);
    }

    public List<CustomerDTO> searchCustomersByName(String name) {
        return customerRepository.findByNameContaining(name).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public CustomerDTO createCustomer(CustomerDTO customerDTO) {
        if (customerRepository.existsByEmail(customerDTO.getEmail())) {
            throw new RuntimeException("Customer with email " + customerDTO.getEmail() + " already exists");
        }

        Customer customer = convertToEntity(customerDTO);
        Customer savedCustomer = customerRepository.save(customer);
        return convertToDTO(savedCustomer);
    }

    public CustomerDTO updateCustomer(Long id, CustomerDTO customerDTO) {
        Customer customer = customerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer not found with id: " + id));

        customer.setFirstName(customerDTO.getFirstName());
        customer.setLastName(customerDTO.getLastName());
        customer.setEmail(customerDTO.getEmail());
        customer.setPhoneNumber(customerDTO.getPhoneNumber());
        customer.setDateOfBirth(customerDTO.getDateOfBirth());
        customer.setGender(customerDTO.getGender());
        customer.setAddress(customerDTO.getAddress());
        customer.setEmergencyContact(customerDTO.getEmergencyContact());
        customer.setMedicalHistory(customerDTO.getMedicalHistory());
        customer.setAllergies(customerDTO.getAllergies());

        Customer savedCustomer = customerRepository.save(customer);
        return convertToDTO(savedCustomer);
    }

    public void deleteCustomer(Long id) {
        if (!customerRepository.existsById(id)) {
            throw new RuntimeException("Customer not found with id: " + id);
        }
        customerRepository.deleteById(id);
    }

    private CustomerDTO convertToDTO(Customer customer) {
        CustomerDTO dto = new CustomerDTO();
        dto.setId(customer.getId());
        dto.setFirstName(customer.getFirstName());
        dto.setLastName(customer.getLastName());
        dto.setEmail(customer.getEmail());
        dto.setPhoneNumber(customer.getPhoneNumber());
        dto.setDateOfBirth(customer.getDateOfBirth());
        dto.setGender(customer.getGender());
        dto.setAddress(customer.getAddress());
        dto.setEmergencyContact(customer.getEmergencyContact());
        dto.setMedicalHistory(customer.getMedicalHistory());
        dto.setAllergies(customer.getAllergies());
        return dto;
    }

    private Customer convertToEntity(CustomerDTO dto) {
        Customer customer = new Customer();
        customer.setFirstName(dto.getFirstName());
        customer.setLastName(dto.getLastName());
        customer.setEmail(dto.getEmail());
        customer.setPhoneNumber(dto.getPhoneNumber());
        customer.setDateOfBirth(dto.getDateOfBirth());
        customer.setGender(dto.getGender());
        customer.setAddress(dto.getAddress());
        customer.setEmergencyContact(dto.getEmergencyContact());
        customer.setMedicalHistory(dto.getMedicalHistory());
        customer.setAllergies(dto.getAllergies());
        return customer;
    }
}