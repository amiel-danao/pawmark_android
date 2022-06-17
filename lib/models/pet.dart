class Pet {
  int id;
  String name;
  DateTime dateOfBirth;
  String gender;
  double weight;
  String allergies;
  String existingConditions;
  String breed;
  String species;
  double height;
  String image;
  String owner;

  Pet(
      {this.id = -1,
      required this.name,
      required this.dateOfBirth,
      this.gender = "Male",
      this.weight = 1.0,
      this.height = 1.0,
      required this.species,
      this.allergies = "",
      this.existingConditions = "",
      this.image = "",
      required this.owner,
      this.breed = "NA"});

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
        id: json['id'],
        name: json['name'],
        dateOfBirth: DateTime.parse(json['date_of_birth']),
        gender: json['gender'],
        weight: double.parse(json['weight'].toString()),
        height: double.parse(json['height'].toString()),
        species: json.containsKey('species') ? json['species'] : '',
        allergies: json['allergies'],
        existingConditions: json['existing_conditions'],
        image: json['image'] == null ? '' : json['image'],
        breed: json['breed'] == null ? '' : json['breed'],
        owner: json['owner']);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "date_of_birth": dateOfBirth.toString(),
        "gender": gender,
        "weight": weight.toString(),
        "height": height.toString(),
        "allergies": allergies,
        "existing_conditions": existingConditions,
        "species": species,
        "image": image,
        "breed": breed,
        "owner": owner
      };

  static Pet getNewInstance({required owner}) {
    return Pet(
        name: "", dateOfBirth: DateTime.now(), owner: owner, species: 'Cat');
  }
}
