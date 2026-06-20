class Doctor {
  final String? id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String qualification;
  final double rating;
  final int reviews;
  final int fee;
  final String workingTime;
  final String? imagePath;
  final String? networkImageUrl;

  Doctor({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.qualification,
    required this.rating,
    required this.reviews,
    required this.fee,
    required this.workingTime,
    this.imagePath,
    this.networkImageUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Doctor(
      id: json['id'],
      firstName: profile?['first_name'] ?? json['first_name'] ?? 'Doctor',
      lastName: profile?['last_name'] ?? json['last_name'] ?? '',
      specialty: json['specialty'] ?? 'General Physician',
      qualification: json['qualification'] ?? 'MBBS',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      fee: json['fee'] ?? 0,
      workingTime: json['working_time'] ?? '09:00 AM - 05:00 PM',
      networkImageUrl: json['image_url'],
    );
  }
}

class Challan {
  final String patientName;
  final double consultationFee;
  final double medicineFee;
  final double deliveryFee;
  final String notes;

  Challan({
    required this.patientName,
    required this.consultationFee,
    required this.medicineFee,
    required this.deliveryFee,
    required this.notes,
  });
}

class CurrentDoctor {
  static Doctor? current = Doctor(
    id: "doctor1",
    firstName: "Ahmed",
    lastName: "Khan",
    specialty: "Cardiologist",
    qualification: "MBBS, FCPS",
    rating: 4.8,
    reviews: 120,
    fee: 50,
    workingTime: "09:00 AM - 05:00 PM",
    networkImageUrl: "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
  );

  static List<Doctor> getDummyDoctors() {
    return [
      Doctor(
        id: "doctor2",
        firstName: "Sarah",
        lastName: "Johnson",
        specialty: "Dentist",
        qualification: "BDS, MDS",
        rating: 4.9,
        reviews: 85,
        fee: 40,
        workingTime: "10:00 AM - 06:00 PM",
        networkImageUrl: "https://img.freepik.com/free-photo/pleased-young-female-doctor-white-coat-with-stethoscope-around-neck-standing-with-folded-arms-isolated-white-wall_231208-2200.jpg",
      ),
    ];
  }
}
