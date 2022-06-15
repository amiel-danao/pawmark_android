import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import '../constants/color_constants.dart';
import '../env.sample.dart';
import '../models/pet.dart';
import 'pet_profile_page.dart';

class PetListPage extends StatefulWidget {
  @override
  PetListState createState() => PetListState();
}

class PetListState extends State<PetListPage> {
  late Future<List<Pet>> pets;
  final petListKey = GlobalKey<PetListState>();

  @override
  void initState() {
    super.initState();
    pets = getPetList();
  }

  Future<List<Pet>> getPetList() async {
    print("start getPetList");
    Uri uri = Uri.parse('${Env.URL_PREFIX}/api/petlist?format=json');
    final response = await http.get(uri);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Pet> pets = items.map<Pet>((json) {
      return Pet.fromJson(json);
    }).toList();

    print(items.toString());
    return pets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: petListKey,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          AppConstants.petsPageTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PetProfilePage()));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder<List<Pet>>(
          future: pets,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // By default, show a loading spinner.
            if (!snapshot.hasData) return CircularProgressIndicator();
            // Render Pet lists
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      data.name,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
