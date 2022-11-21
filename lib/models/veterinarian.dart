class Veterinarian {
  final String id;
  final String email;
  final String firstname;
  final String middlename;
  final String lastname;
  final String picture;
  final String aboutMe;

  Veterinarian(
      {required this.id,
      required this.email,
      this.firstname = "",
      this.middlename = "",
      this.lastname = "",
      this.picture = "",
      this.aboutMe = ""});

  factory Veterinarian.fromJson(Map<String, dynamic> json) {
    return Veterinarian(
      id: json['id'],
      email: json['email'],
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname'],
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstname': firstname,
        'middlename': middlename,
        'lastname': lastname,
        'picture': picture,
      };
}
