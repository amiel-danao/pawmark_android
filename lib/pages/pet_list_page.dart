import 'dart:async';
import 'dart:convert';

import 'package:auth_service/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_demo/pages/medical_history_list_page.dart';
import 'package:flutter_chat_demo/pages/profile_page.dart';
import 'package:flutter_chat_demo/pages/immunization_history_list_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../api/customer_controller.dart';
import '../api/pet_controller.dart';
import '../constants/app_constants.dart';
import '../constants/color_constants.dart';
import '../env.sample.dart';
import '../login/view/login_view.dart';
import '../models/pet.dart';
import '../models/popup_choices.dart';
import '../providers/auth_provider.dart';
import '../themes/flutter_flow_theme.dart';
import '../pages/pet_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'my_nav_drawer.dart';

class PetListPage extends StatefulWidget {
  final Customer currentCustomer;
  const PetListPage({Key? key, required this.currentCustomer})
      : super(key: key);

  @override
  _PetListPageState createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Future<List<Pet>> pets;
  StreamController<List<Pet>> petStream = StreamController<List<Pet>>();
  var petImages = Map<String, String>();
  late AuthProvider authProvider;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    //pets = getPetList();
    loadMyPets();
  }

  void loadMyPets() async {
    print("start getBreeds");
    print("start getPetList");
    Uri uri = Uri.parse(
        '${Env.URL_PREFIX}/api/${Env.URL_PETLIST}?owner=${auth.currentUser!.uid}&format=json');
    final response = await http.get(uri);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Pet> pets = items.map<Pet>((json) {
      return Pet.fromJson(json);
    }).toList();

    for (var i = 0; i < pets.length; i++) {
      loadPetImage(
          pets[i].id,
          (value) => setState(() {
                petImages[pets[i].id] = value;
              }));
    }

    print(uri);
    print(items.toString());

    petStream.add(pets);
  }

  Future<List<Pet>> getPetList() async {
    print("start getPetList");
    Uri uri = Uri.parse(
        '${Env.URL_PREFIX}/api/${Env.URL_PETLIST}?owner=${auth.currentUser!.uid}&format=json');
    final response = await http.get(uri);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Pet> pets = items.map<Pet>((json) {
      return Pet.fromJson(json);
    }).toList();

    print(uri);
    print(items.toString());
    return pets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: MyNavDrawer(
        counter: counter,
        currentCustomer: widget.currentCustomer,
        signOutFunction: () {
          handleSignOut(context, authProvider);
        },
      ),
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          AppConstants.petsPageTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[buildPopupMenu()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PetProfilePage(
                      currentCustomer: widget.currentCustomer,
                      petData:
                          Pet.getNewInstance(owner: auth.currentUser!.uid))));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          loadMyPets();
        },
        child: StreamBuilder(
            stream: petStream.stream,

            // FutureBuilder<List<Pet>>(
            //     future: pets,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // By default, show a loading spinner.
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              else if (snapshot.data.length == 0)
                return Center(child: Text('You have no existing pet yet.'));
              // Render Pet lists
              return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var data = snapshot.data[index];
                    return petCardEntry(data);
                  });
            }),
      ),
    );
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      handleSignOut(context, authProvider);
    }
  }

  Widget petCardEntry(data) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Color(0xFFF5F5F5),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 100,
        height: 200,
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetProfilePage(
                    currentCustomer: widget.currentCustomer, petData: data),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(children: [
                Align(
                  alignment: AlignmentDirectional(1, -1),
                  child: IconButton(
                    icon: Icon(
                      Icons.history_edu_outlined,
                      color: FlutterFlowTheme.of(context).primaryColor,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MedicalHistoryPage(petData: data)));
                    },
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.7, 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.vaccines,
                      color: ColorConstants.primaryColor,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImmunizationHistoryPage(petData: data)));
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1, -1),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                        child: Container(
                          width: 120,
                          height: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: '${petImages[data.id]}',
                            placeholder: (context, url) => Image.asset(
                                'images/app_icon.png',
                                fit: BoxFit.fitWidth),
                            errorWidget: (context, url, error) => Image.asset(
                                'images/app_icon.png',
                                fit: BoxFit.fitWidth),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: ListTile(
                          title: Text(data.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text('${data.species} - ${data.breed}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal)),
                          tileColor: Color(0xFFF5F5F5),
                          dense: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                data.gender == "Male"
                                    ? FontAwesomeIcons.mars
                                    : FontAwesomeIcons.venus,
                                color: data.gender == "Male"
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Colors.pink,
                                size: 24,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.gender,
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.weight.toString(),
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('kg',
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.height.toString(),
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('cm',
                                  style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }
}
