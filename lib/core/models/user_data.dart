class UserData {
  final String fullName;
  final String email;
  final String password;
  final String organizationName;
  final String? reference;

  UserData({
    required this.fullName,
    required this.email,
    required this.password,
    required this.organizationName,
    this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'organizationName': organizationName,
      'reference': reference,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: json['fullName'],
      email: json['email'],
      password: json['password'],
      organizationName: json['organizationName'],
      reference: json['reference'],
    );
  }
}