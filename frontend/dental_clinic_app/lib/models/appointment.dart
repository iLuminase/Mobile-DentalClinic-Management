class Appointment {
  final int? id;
  final int customerId;
  final int employeeId;
  final String? customerName;
  final String? employeeName;
  final DateTime appointmentDateTime;
  final int durationMinutes;
  final AppointmentStatus status;
  final String serviceType;
  final String? description;
  final String? notes;
  final double? cost;

  Appointment({
    this.id,
    required this.customerId,
    required this.employeeId,
    this.customerName,
    this.employeeName,
    required this.appointmentDateTime,
    this.durationMinutes = 60,
    this.status = AppointmentStatus.scheduled,
    required this.serviceType,
    this.description,
    this.notes,
    this.cost,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      customerId: json['customerId'],
      employeeId: json['employeeId'],
      customerName: json['customerName'],
      employeeName: json['employeeName'],
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']),
      durationMinutes: json['durationMinutes'] ?? 60,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
      serviceType: json['serviceType'],
      description: json['description'],
      notes: json['notes'],
      cost: json['cost']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'employeeId': employeeId,
      'customerName': customerName,
      'employeeName': employeeName,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status.toString().split('.').last.toUpperCase(),
      'serviceType': serviceType,
      'description': description,
      'notes': notes,
      'cost': cost,
    };
  }

  DateTime get endTime => appointmentDateTime.add(Duration(minutes: durationMinutes));
}

enum AppointmentStatus { 
  scheduled, 
  confirmed, 
  inProgress, 
  completed, 
  cancelled, 
  noShow 
}