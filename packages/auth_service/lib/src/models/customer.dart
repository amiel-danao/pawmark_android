import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.mobile,
    this.picture,
  });

  final String id;
  final String? firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? mobile;
  final String? picture;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? "",
        firstName: json['firstname'] ?? "",
        middleName: json['middlename'] ?? "",
        lastName: json['lastname'] ?? "",
        email: json['email'] ?? "",
        mobile: json['mobile'] ?? "",
        picture: json['picture'] ?? "",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstname': firstName,
        'middlename': middleName,
        'lastname': lastName,
        'email': email,
        'mobile': mobile
      };

  factory Customer.empty() => const Customer(
        id: "",
        firstName: "",
        middleName: "",
        lastName: "",
        email: "",
        mobile: "",
        picture: "",
      );
  @override
  List<Object?> get props =>
      [id, firstName, middleName, lastName, email, mobile, picture];
}
