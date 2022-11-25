import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auth_service/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import '../api/pet_controller.dart';
import '../constants/app_constants.dart';
import '../constants/color_constants.dart';
import '../env.sample.dart';
import '../models/breed.dart';
import '../models/pet.dart';
import '../pages/pet_list_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PetProfilePage extends StatefulWidget {
  final Pet petData;
  final Customer currentCustomer;
  const PetProfilePage(
      {Key? key, required this.petData, required this.currentCustomer})
      : super(key: key);

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  String uploadedFileUrl = '';
  late TextEditingController nameController;
  late TextEditingController dateOfBirthController;
  late TextEditingController genderController;
  late TextEditingController speciesController;
  late TextEditingController breedController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController allergiesController;
  late TextEditingController existingConditionsController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  late StreamController<List<Breed>> breedStream;

  String petImage = '';

  late Future<File> imageFile;

  @override
  void initState() {
    super.initState();
    print(widget.petData.toString());
    dateOfBirthController = TextEditingController(
        text: formatter.format(widget.petData.dateOfBirth));
    nameController = TextEditingController(text: widget.petData.name);
    genderController = TextEditingController(text: widget.petData.gender);
    speciesController = TextEditingController(text: widget.petData.species);
    breedController = TextEditingController(text: widget.petData.breed);
    weightController =
        TextEditingController(text: widget.petData.weight.toString());
    heightController =
        TextEditingController(text: widget.petData.height.toString());
    existingConditionsController =
        TextEditingController(text: widget.petData.existingConditions);
    allergiesController = TextEditingController(text: widget.petData.allergies);

    breedStream = StreamController<List<Breed>>();

    loadPetImage(
        widget.petData.id,
        (value) => setState(() {
              petImage = value;
            }));
    loadBreeds(widget.petData.species);
    print(widget.petData.toJson());
  }

  void loadBreeds(species) async {
    print("start getBreeds");
    Uri uri = Uri.parse(
        '${Env.URL_PREFIX}/api/breedlist?species=$species&format=json');
    final response = await http.get(uri);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Breed> breeds = items.map<Breed>((json) {
      return Breed.fromJson(json);
    }).toList();

    breedStream.add(breeds);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.petData.dateOfBirth,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != widget.petData.dateOfBirth) {
      setState(() {
        widget.petData.dateOfBirth = picked;
        dateOfBirthController.text = formatter.format(picked);
      });
    }
  }

  Future<http.Response> savePetData() {
    String urlCommand = '${Env.URL_PET}';
    if (widget.petData.id.isNotEmpty) {
      urlCommand = '${Env.URL_PET}/${widget.petData.id}';

      return http.put(
        Uri.parse(urlCommand),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(widget.petData.toJson()),
      );
    }

    return http.post(
      Uri.parse(urlCommand),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(widget.petData.toJson()),
    );
  }

  Future<http.Response> deletePet() {
    String urlCommand = '${Env.URL_PET}/${widget.petData.id}';

    return http.delete(Uri.parse(urlCommand), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          AppConstants.petProfileTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xFFDBE2E7),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: 90,
                              height: 90,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: petImage,
                                placeholder: (context, url) => Image.asset(
                                    'images/app_icon.png',
                                    fit: BoxFit.fitWidth),
                                errorWidget: (context, url, error) =>
                                    Image.asset('images/app_icon.png',
                                        fit: BoxFit.fitWidth),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                if (widget.petData.id.isNotEmpty) {
                                  uploadImage(
                                      '${Env.URL_PET_IMAGE}/${widget.petData.id}',
                                      'image',
                                      {'id': widget.petData.id},
                                      context,
                                      (value) => setState(() {
                                            petImage = value;
                                          }));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "New Pet data should be saved first!"),
                                  ));
                                }
                              },
                              child: Text('Change Photo')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                      child: TextFormField(
                        controller: nameController,
                        onChanged: (val) => widget.petData.name = val,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.pets,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: dateOfBirthController,
                        onTap: () => _selectDate(context),
                        //onFieldSubmitted: ()=> _selectDate(context),
                        obscureText: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.cake,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                            child: DropdownButtonFormField(
                                value: widget.petData.gender,
                                items: ['Male', 'Female'].map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    widget.petData.gender = newValue!;
                                  });
                                },
                                hint: Text('Gender'),
                                isExpanded: true,
                                decoration: InputDecoration(
                                    suffixIcon: FaIcon(
                                      FontAwesomeIcons.venusMars,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ))),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                            child: DropdownButtonFormField(
                                isExpanded: true,
                                value: widget.petData.species,
                                items: ['Cat', 'Dog'].map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != widget.petData.species) {
                                      widget.petData.breed = "";
                                    }
                                    loadBreeds(newValue);
                                    widget.petData.species = newValue!;
                                  });
                                },
                                hint: Text('Species'),
                                decoration: InputDecoration(
                                    suffixIcon: FaIcon(
                                      FontAwesomeIcons.shapes,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ))),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                              child: //FutureBuilder(
                                  //future: catBreeds,
                                  StreamBuilder(
                                      stream: breedStream.stream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return DropdownButtonFormField(
                                            hint: Text('Select Breed'),
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                                suffixIcon: Icon(
                                                  Icons.merge_type_sharp,
                                                  size: 15,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .backgroundColor,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .backgroundColor,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                )),
                                            items: snapshot.data
                                                .map<DropdownMenuItem<String>>(
                                                    (Breed breed) {
                                              return DropdownMenuItem<String>(
                                                value: breed.breedName,
                                                child: Text(breed.breedName,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            58, 66, 46, .9))),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() => {
                                                    widget.petData.breed =
                                                        newValue!
                                                  });
                                            },
                                          );
                                        }
                                        return CircularProgressIndicator();
                                      })),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        onChanged: (String? newValue) {
                          setState(() {
                            widget.petData.weight = double.parse(newValue!);
                            // weightController.text = newValue;
                          });
                        },
                        controller: weightController,
                        obscureText: false,
                        decoration: InputDecoration(
                          suffixText: 'kg',
                          labelText: 'Weight',
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          hintText: 'kg',
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.weightScale,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        onChanged: (String? newValue) {
                          setState(() {
                            widget.petData.height = double.parse(newValue!);
                            // heightController.text = newValue;
                          });
                        },
                        controller: heightController,
                        obscureText: false,
                        decoration: InputDecoration(
                          suffixText: 'cm',
                          labelText: 'Shoulder Height',
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          hintText: 'cm',
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.rulerVertical,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        onChanged: (String? newValue) {
                          setState(() {
                            widget.petData.allergies = newValue!;
                          });
                        },
                        controller: allergiesController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Allergies',
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.sith,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        onChanged: (String? newValue) {
                          setState(() {
                            widget.petData.existingConditions = newValue!;
                          });
                        },
                        controller: existingConditionsController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Existing Conditions',
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.sick,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0, 0.05),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: TextButton(
                  child: Text('Save Changes'),
                  onPressed: () async {
                    final response = await savePetData();
                    if (response.statusCode == 201 ||
                        response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Pet data saved successfully"),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Error saving Pet data. ${response.body}"),
                      ));
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.white; // Use the component's default.
                      },
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return ColorConstants.primaryColor.withOpacity(0.5);
                        return ColorConstants
                            .primaryColor; // Use the component's default.
                      },
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1, 0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 10, 0),
                child: InkWell(
                  onTap: () async {
                    var confirmDialogResponse = await showDialog<bool>(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: Text('Delete Pet Info'),
                              content: Text(
                                  'Are you sure you want to delete this Pet Info?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final response = await deletePet();
                                    if (response.statusCode == 204) {
                                      print(widget.petData.toJson());
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                    if (confirmDialogResponse) {
                      await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          duration: Duration(milliseconds: 300),
                          reverseDuration: Duration(milliseconds: 300),
                          child: PetListPage(
                              currentCustomer: widget.currentCustomer),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Delete Pet Info',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFE91E63),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
