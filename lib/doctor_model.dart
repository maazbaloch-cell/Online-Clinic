class Doctor {
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
    firstName: "Dr. Ahmed",
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
        firstName: "Dr. Sarah",
        lastName: "Johnson",
        specialty: "Dentist",
        qualification: "BDS, MDS",
        rating: 4.9,
        reviews: 85,
        fee: 40,
        workingTime: "10:00 AM - 06:00 PM",
        networkImageUrl: "https://img.freepik.com/free-photo/pleased-young-female-doctor-white-coat-with-stethoscope-around-neck-standing-with-folded-arms-isolated-white-wall_231208-2200.jpg",
      ),
      Doctor(
        firstName: "Dr. Michael",
        lastName: "Smith",
        specialty: "Cardiologist",
        qualification: "MD, FACC",
        rating: 4.7,
        reviews: 150,
        fee: 70,
        workingTime: "08:00 AM - 04:00 PM",
        networkImageUrl: "https://img.freepik.com/free-photo/doctor-with-stethoscope-hands-folded_1154-491.jpg",
      ),
      Doctor(
        firstName: "Dr. Emily",
        lastName: "Davis",
        specialty: "Allergist",
        qualification: "MD, PhD",
        rating: 4.6,
        reviews: 60,
        fee: 35,
        workingTime: "09:00 AM - 05:00 PM",
        networkImageUrl: "https://img.freepik.com/free-photo/smiling-female-doctor-white-coat-standing-with-arms-crossed-white-background_231208-2144.jpg",
      ),
    ];
  }
}
