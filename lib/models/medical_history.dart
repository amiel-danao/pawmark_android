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
        description: json['description'] == null ? "" : json['description'],
        veterinarian: json['veterinarian'] == null ? "" : json['veterinarian'],
        diagnosis: json['diagnosis'] == null ? "" : json['diagnosis'],
        testsPerformed:
            json['tests_performed'] == null ? "" : json['tests_performed'],
        testResults: json['test_results'] == null ? "" : json['test_results'],
        action: json['action'] == null ? "" : json['action'],
        medication: json['medication'] == null ? "" : json['medication']);
  }
}
