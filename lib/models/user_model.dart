class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String status;
  final String profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.status = "Verified Profile",
    this.profileImageUrl = "https://i.pravatar.cc/300",
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'status': status,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      status: map['status'] ?? 'Verified Profile',
      profileImageUrl: map['profileImageUrl'] ?? 'https://i.pravatar.cc/300',
    );
  }
}
