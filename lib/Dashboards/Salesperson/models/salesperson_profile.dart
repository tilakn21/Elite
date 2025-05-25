// Model for Salesperson profile data
class SalespersonProfile {
  final String fullName;
  final String phoneNumber;
  final String email;
  final int age;

  SalespersonProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.age,
  });

  factory SalespersonProfile.fromMap(Map<String, dynamic> map) {
    return SalespersonProfile(
      fullName: map['fullName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'age': age,
    };
  }
}
