class ImmunizationHistory {
  String pet;
  int petAge;
  String vaccine;
  DateTime date;
  String veterinarian;

  ImmunizationHistory({
    this.pet = "",
    this.petAge = 1,
    this.vaccine = "",
    this.veterinarian = "",
    required this.date,
  });

  factory ImmunizationHistory.fromJson(Map<String, dynamic> json) {
    return ImmunizationHistory(
      pet: json['pet'],
      petAge: json['pet_age'],
      vaccine: json['vaccine'],
      veterinarian: json['veterinarian'],
      date: DateTime.parse(json['date']),
    );
  }
}
