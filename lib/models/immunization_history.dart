class ImmunizationHistory {
  String pet;
  int petAge;
  String vaccine;
  DateTime date;
  String veterinarian;
  int dose;
  String ownerActions;
  String veterinaryActions;
  String attachment;

  ImmunizationHistory(
      {this.pet = "",
      this.petAge = 1,
      this.vaccine = "",
      this.veterinarian = "",
      this.dose = 1,
      this.ownerActions = "",
      this.veterinaryActions = "",
      required this.date,
      this.attachment = ""});

  factory ImmunizationHistory.fromJson(Map<String, dynamic> json) {
    return ImmunizationHistory(
        pet: json['pet'],
        petAge: json['pet_age'],
        vaccine: json['vaccine'],
        veterinarian: json['veterinarian'],
        date: DateTime.parse(json['date']),
        dose: json['dose'],
        ownerActions: json['owner_actions'],
        veterinaryActions: json['veterinary_actions'],
        attachment: json['attachment'] ?? '');
  }
}
