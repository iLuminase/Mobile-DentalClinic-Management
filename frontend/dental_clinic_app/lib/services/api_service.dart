import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../models/customer.dart';
import '../models/appointment.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Employee API calls
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  Future<Employee> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/employees'),
        headers: headers,
        body: json.encode(employeeData),
      );

      if (response.statusCode == 201) {
        return Employee.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create employee: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating employee: $e');
    }
  }

  Future<Employee> updateEmployee(int id, Employee employee) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/employees/$id'),
        headers: headers,
        body: json.encode(employee.toJson()),
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update employee: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating employee: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/employees/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete employee: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting employee: $e');
    }
  }

  // Customer API calls
  Future<List<Customer>> getCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: headers,
        body: json.encode(customer.toJson()),
      );

      if (response.statusCode == 201) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  Future<Customer> updateCustomer(int id, Customer customer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/$id'),
        headers: headers,
        body: json.encode(customer.toJson()),
      );

      if (response.statusCode == 200) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  // Appointment API calls
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/employee/$employeeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByCustomer(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/customer/$customerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: headers,
        body: json.encode(appointment.toJson()),
      );

      if (response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }

  Future<Appointment> updateAppointment(int id, Appointment appointment) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: headers,
        body: json.encode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/appointments/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete appointment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }
}