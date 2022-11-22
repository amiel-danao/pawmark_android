import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.picture,
  });

  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? picture;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? "",
        firstName: json['firstName'] ?? "",
        middleName: json['middleName'] ?? "",
        lastName: json['lastName'] ?? "",
        email: json['email'] ?? "",
        picture: json['picture'] ?? "",
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email
      };

  factory Customer.empty() => const Customer(
        id: "",
        firstName: "",
        middleName: "",
        lastName: "",
        email: "",
        picture: "",
      );
  @override
  List<Object?> get props =>
      [id, firstName, middleName, lastName, email, picture];
}
