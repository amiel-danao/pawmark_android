class Pet {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final int petAge;
  final String gender;
  final double weight;
  final String allergies;
  final String existingConditions;
  final String breed;
  final String species;
  final double height;
  final String image;

  Pet(
      {required this.id,
      required this.name,
      required this.dateOfBirth,
      required this.petAge,
      required this.gender,
      required this.weight,
      required this.allergies,
      required this.existingConditions,
      required this.breed,
      required this.species,
      required this.height,
      required this.image});

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
        id: json['id'],
        name: json['name'],
        dateOfBirth: DateTime.parse(json['date_of_birth']),
        petAge: json['pet_age'],
        gender: json['gender'],
        weight: double.parse(json['weight'].toString()),
        allergies: json['allergies'],
        existingConditions: json['existing_conditions'],
        breed: json['breed'],
        species: json['species'],
        height: double.parse(json['height'].toString()),
        image: json['image']);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "date_of_birth": dateOfBirth.toString(),
        "pet_age": petAge,
        "gender": gender,
        "weight": weight.toString(),
        "allergies": allergies,
        "existing_conditions": existingConditions,
        "breed": breed,
        "species": species,
        "height": height,
        "image": image
      };
}
