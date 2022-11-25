import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../env.sample.dart';
import '../models/medical_history.dart';
import '../models/pet.dart';

class MedicalHistoryPage extends StatefulWidget {
  final Pet petData;
  const MedicalHistoryPage({Key? key, required this.petData}) : super(key: key);

  @override
  _MedicalHistoryPageState createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<List<MedicalHistory>> medicalStream =
      StreamController<List<MedicalHistory>>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadMedicalHistory();
  }

  void loadMedicalHistory() async {
    print("start medical histories");
    Uri uri = Uri.parse(
        '${Env.URL_PREFIX}/api/${Env.URL_MEDICALLIST}?pet=${widget.petData.id}&format=json');
    final response = await http.get(uri);

    try {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<MedicalHistory> medicals = items.map<MedicalHistory>((json) {
        return MedicalHistory.fromJson(json);
      }).toList();

      print(uri);
      print(items.toString());

      medicalStream.add(medicals);
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
        automaticallyImplyLeading: false,
        title: Text(
          'Medical History of ${widget.petData.name}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          onRefresh: () async {
            loadMedicalHistory();
          },
          child: StreamBuilder(
              stream: medicalStream.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // By default, show a loading spinner.
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                else if (snapshot.data.length == 0)
                  return Center(child: Text('No medical history data.'));
                return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: false,
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data[index];
                      return medicalEntry(data);
                    });
              })),
    );
  }

  Widget medicalEntry(data) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      child: Container(
        width: 100,
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
                    Text(
                      'Veterinarian: ${data.veterinarian}',
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                  ],
                ),
              ),
              Text(
                'Diagnosis: ${data.diagnosis}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Test results: ${data.testResults}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${formatter.format(data.date)}',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
