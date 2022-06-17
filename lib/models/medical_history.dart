class MedicalHistory {
  int pet;
  DateTime date;
  String description;
  String veterinarian;
  String diagnosis;
  String testsPerformed;
  String testResults;
  String action;
  String medication;

  MedicalHistory(
      {this.pet = -1,
      required this.date,
      this.description = "",
      required this.veterinarian,
      this.diagnosis = "",
      this.testsPerformed = "",
      this.testResults = "",
      this.action = "",
      this.medication = ""});

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
        pet: json['pet'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        veterinarian: json['veterinarian'],
        diagnosis: json['diagnosis'],
        testsPerformed: json['testsPerformed'],
        testResults: json['testResults'],
        action: json['action'],
        medication: json['medication']);
  }
}
