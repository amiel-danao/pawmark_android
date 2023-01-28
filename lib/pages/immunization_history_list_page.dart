import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_demo/pages/vaccine_detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../env.sample.dart';
import '../models/medical_history.dart';
import '../models/pet.dart';
import '../models/immunization_history.dart';

class ImmunizationHistoryPage extends StatefulWidget {
  final Pet petData;
  const ImmunizationHistoryPage({Key? key, required this.petData})
      : super(key: key);

  @override
  _ImmunizationHistoryPageState createState() =>
      _ImmunizationHistoryPageState();
}

class _ImmunizationHistoryPageState extends State<ImmunizationHistoryPage> {
  final dateFormat = DateFormat('MMMM-dd-yyyy – KK:mm a');
  final scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<List<ImmunizationHistory>> immunizationStream =
      StreamController<List<ImmunizationHistory>>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadImmunizationHistory();
  }

  void loadImmunizationHistory() async {
    print("start immunization histories");
    Uri uri = Uri.parse(
        '${Env.URL_PREFIX}/api/${Env.URL_IMMUNIZATIONLIST}?pet=${widget.petData.id}&format=json');
    final response = await http.get(uri);

    try {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<ImmunizationHistory> immunizations =
          items.map<ImmunizationHistory>((json) {
        return ImmunizationHistory.fromJson(json);
      }).toList();

      print(uri);
      print(items.toString());

      immunizationStream.add(immunizations);
    } on Exception catch (exception) {
      print(
          exception.toString()); // only executed if error is of type Exception
    } catch (error) {
      print(error
          .toString()); // executed for errors of all types other than Exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: ColorConstants.primaryColor,
          // automaticallyImplyLeading: false,
          title: Text(
            'Immunization History of ${widget.petData.name}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            loadImmunizationHistory();
          },
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                  stream: immunizationStream.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // By default, show a loading spinner.
                    if (snapshot.hasData == false ||
                        snapshot.data.length == 0 ||
                        snapshot.hasError)
                      return Center(
                          child: Text('No Immunization history data.'));
                    else if (snapshot.connectionState ==
                        ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          var data = snapshot.data[index];
                          return immunizationEntry(data);
                        });
                  })),
        ));
  }

  Widget immunizationEntry(data) {
    return OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VaccineDetailsPageWidget(vaccineRecord: data)));
        },
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  color: Color(0x3B000000),
                  offset: Offset(0, 2),
                )
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Type of Vaccine: ${data.vaccine}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))
                      ],
                    ),
                  ),
                  Text(
                    'Date: ${dateFormat.format(data.date)}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    'Pet Age: ${data.petAge}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attending Doctor: ${data.veterinarian}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
