import 'address_model.dart';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final int gender;
  final AddressModel? address;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: int.tryParse(json['gender'].toString()) ?? 0,
      address:
          json['address'] != null
              ? AddressModel.fromJson(json['address'])
              : null,
    );
  }
}
