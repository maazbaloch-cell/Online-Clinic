class AppointmentModel {
  final String? id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;

  AppointmentModel({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.timeSlot,
    this.status = 'pending',
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'date': date.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      doctorId: json['doctor_id'],
      patientId: json['patient_id'],
      doctorName: json['doctor_name'],
      patientName: json['patient_name'],
      date: DateTime.parse(json['date']),
      timeSlot: json['time_slot'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
