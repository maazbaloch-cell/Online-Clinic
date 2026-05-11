class PatientModel {
  final String? imagePath;
  final String name;
  final String email;
  final String password;
  final int age;
  final String cnic;
  final String gender;
  final String city;
  final String address;

  PatientModel({
    this.imagePath,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.cnic,
    required this.gender,
    required this.city,
    required this.address,
  });

  static List<PatientModel> patients = [
    PatientModel(
      name: "Ali Khan",
      email: "ali@example.com",
      password: "123",
      age: 22,
      cnic: "12345",
      gender: "Male",
      city: "Karachi",
      address: "DHA Phase 5",
      imagePath: "",
    ),
    PatientModel(
      name: "Sana Ahmed",
      email: "sana@example.com",
      password: "123",
      age: 28,
      cnic: "54321",
      gender: "Female",
      city: "Lahore",
      address: "Gulberg III",
      imagePath: "",
    ),
  ];
}
