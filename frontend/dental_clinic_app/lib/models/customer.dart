class Customer {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? emergencyContact;
  final String? medicalHistory;
  final String? allergies;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContact,
    this.medicalHistory,
    this.allergies,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'] != null 
          ? Gender.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() == json['gender'],
            )
          : null,
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender?.toString().split('.').last.toUpperCase(),
      'address': address,
      'emergencyContact': emergencyContact,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
    };
  }

  String get fullName => '$firstName $lastName';
}

enum Gender { male, female, other }