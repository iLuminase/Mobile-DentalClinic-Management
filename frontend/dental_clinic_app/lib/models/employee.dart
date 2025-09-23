class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final EmployeeRole role;
  final EmployeeStatus status;
  final String? specialization;
  final String? licenseNumber;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.status = EmployeeStatus.active,
    this.specialization,
    this.licenseNumber,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: EmployeeRole.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['role'],
      ),
      status: EmployeeStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
      'specialization': specialization,
      'licenseNumber': licenseNumber,
    };
  }

  String get fullName => '$firstName $lastName';
}

enum EmployeeRole { admin, dentist, receptionist, assistant }

enum EmployeeStatus { active, inactive, suspended }