class Breed {
  final String breedName;
  final String species;

  Breed({required this.breedName, required this.species});

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(breedName: json['breed_name'], species: json['species']);
  }

  Map<String, dynamic> toJson() =>
      {'breed_name': breedName, 'species': species};
}
