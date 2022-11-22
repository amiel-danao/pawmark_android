class Customer {
  final String id;
  final String? email;
  final String firstname;
  final String middlename;
  final String lastname;
  final String picture;

  Customer(
      {required this.id,
        required this.email,
        this.firstname = "",
        this.middlename = "",
        this.lastname = "",
        this.picture = ""});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      email: json['email'],
      firstname: json['firstname'],
      middlename: json['middlename'],
      lastname: json['lastname']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstname': firstname,
    'middlename': middlename,
    'lastname': lastname
  };
}
