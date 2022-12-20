import 'package:flutter_chat_demo/models/medical_history.dart';
import 'package:intl/intl.dart';
import '../constants/color_constants.dart';
import '../models/pet.dart';
import 'package:flutter/material.dart';

class MedicalHistoryDetailPage extends StatefulWidget {
  final MedicalHistory currentMedicalHistory;
  final Pet currentPet;
  const MedicalHistoryDetailPage(
      {Key? key, required this.currentPet, required this.currentMedicalHistory})
      : super(key: key);

  @override
  _MedicalHistoryDetailPageState createState() =>
      _MedicalHistoryDetailPageState();
}

class _MedicalHistoryDetailPageState extends State<MedicalHistoryDetailPage> {
  final dateFormat = DateFormat('MMMM-dd-yyyy – KK:mm a');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          'Medical History of ${widget.currentPet.name}',
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
                    const SizedBox(height: 30.0),
                    _detailRowText(
                        "Date: ${dateFormat.format(widget.currentMedicalHistory.date)}"),
                    _detailRowText(
                        "Description: ${widget.currentMedicalHistory.description}"),
                    _detailRowText(
                        "Veterinarian: ${widget.currentMedicalHistory.veterinarian}"),
                    _detailRowText(
                        "Tests Performed: ${widget.currentMedicalHistory.testsPerformed}"),
                    _detailRowText(
                        "Test Results: ${widget.currentMedicalHistory.testResults}"),
                    _detailRowText(
                        "Medicine: ${widget.currentMedicalHistory.medication}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRowText(String text) {
    return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )));
  }
}
