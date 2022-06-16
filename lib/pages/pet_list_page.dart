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
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data[index];
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(-1, -1),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 10, 10, 10),
                                    child: InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            child: FlutterFlowExpandedImageView(
                                              image: Image.network(
                                                data.image,
                                                fit: BoxFit.contain,
                                              ),
                                              allowRotation: false,
                                              tag: 'circleImageTag',
                                              useHeroAnimation: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: 'circleImageTag',
                                        transitionOnUserGestures: true,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.network(
                                            data.image,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0, 0),
                                    child: ListTile(
                                      title: Text(
                                        data.name,
                                        style:
                                            FlutterFlowTheme.of(context).title3,
                                      ),
                                      subtitle: Text(
                                        '${data.species} - ${data.breed}',
                                        style: FlutterFlowTheme.of(context)
                                            .subtitle2,
                                      ),
                                      tileColor: Color(0xFFF5F5F5),
                                      dense: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.mars,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryColor,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data.gender,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyText1
                                                      .override(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryColor,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data.weight,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyText1
                                                      .override(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 16,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'kg',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyText1
                                                      .override(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data.height,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyText1
                                                      .override(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 16,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'cm',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyText1
                                                      .override(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                      ),
                                            ),
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
                    );
              },
            );
          },
        ),
      ),
    );
  }
}
