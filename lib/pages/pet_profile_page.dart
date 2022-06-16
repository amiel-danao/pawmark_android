import '../backend/firebase_storage/storage.dart';
import '../flutter_flow/flutter_flow_drop_down.dart';
import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../flutter_flow/upload_media.dart';
import '../custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PetProfilePageWidget extends StatefulWidget {
  const PetProfilePageWidget({Key key}) : super(key: key);

  @override
  _PetProfilePageWidgetState createState() => _PetProfilePageWidgetState();
}

class _PetProfilePageWidgetState extends State<PetProfilePageWidget> {
  DateTime datePicked;
  TextEditingController dateOfBirthController;
  String uploadedFileUrl = '';
  TextEditingController yourNameController;
  String genderValue;
  String speciesValue;
  String breedValue;
  TextEditingController weightController;
  TextEditingController heightController;
  TextEditingController allergiesController;
  TextEditingController existingConditionsController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    allergiesController = TextEditingController();
    dateOfBirthController = TextEditingController();
    yourNameController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    existingConditionsController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 14),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 50,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 30,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 0, 0),
                  child: Text(
                    'Edit Pet Info',
                    style: FlutterFlowTheme.of(context).title2.override(
                          fontFamily: 'Poppins',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 22,
                        ),
                  ),
                ),
              ],
            ),
          ),
          actions: [],
          elevation: 0,
        ),
      ),
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                              child: Image.network(
                                'https://images.unsplash.com/photo-1536164261511-3a17e671d380?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=630&q=80',
                                fit: BoxFit.fitWidth,
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
                          FFButtonWidget(
                            onPressed: () async {
                              final selectedMedia = await selectMedia(
                                mediaSource: MediaSource.photoGallery,
                                multiImage: false,
                              );
                              if (selectedMedia != null &&
                                  selectedMedia.every((m) => validateFileFormat(
                                      m.storagePath, context))) {
                                showUploadMessage(
                                  context,
                                  'Uploading file...',
                                  showLoading: true,
                                );
                                final downloadUrls = (await Future.wait(
                                        selectedMedia.map((m) async =>
                                            await uploadData(
                                                m.storagePath, m.bytes))))
                                    .where((u) => u != null)
                                    .toList();
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                if (downloadUrls != null &&
                                    downloadUrls.length ==
                                        selectedMedia.length) {
                                  setState(() =>
                                      uploadedFileUrl = downloadUrls.first);
                                  showUploadMessage(
                                    context,
                                    'Success!',
                                  );
                                } else {
                                  showUploadMessage(
                                    context,
                                    'Failed to upload media',
                                  );
                                  return;
                                }
                              }
                            },
                            text: 'Change Photo',
                            options: FFButtonOptions(
                              width: 130,
                              height: 40,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Lexend Deca',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                              elevation: 1,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                      child: TextFormField(
                        controller: yourNameController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: FlutterFlowTheme.of(context).bodyText2,
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.pets,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: dateOfBirthController,
                        onFieldSubmitted: (_) async {
                          await DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (date) {
                              setState(() => datePicked = date);
                            },
                            currentTime: getCurrentTimestamp,
                            minTime: DateTime(0, 0, 0),
                          );
                        },
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          labelStyle: FlutterFlowTheme.of(context).bodyText2,
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.cake,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
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
                            child: FlutterFlowDropDown(
                              options: ['Male', 'Female'],
                              onChanged: (val) =>
                                  setState(() => genderValue = val),
                              width: 180,
                              height: 40,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                              hintText: 'Gender',
                              icon: FaIcon(
                                FontAwesomeIcons.venusMars,
                              ),
                              fillColor: Colors.white,
                              elevation: 2,
                              borderColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              borderWidth: 1,
                              borderRadius: 2,
                              margin: EdgeInsetsDirectional.fromSTEB(
                                  12, 12, 12, 12),
                              hidesUnderline: true,
                            ),
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
                            child: FlutterFlowDropDown(
                              options: ['Cat', 'Docg'],
                              onChanged: (val) =>
                                  setState(() => speciesValue = val),
                              width: 180,
                              height: 40,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                              hintText: 'Species',
                              icon: FaIcon(
                                FontAwesomeIcons.shapes,
                              ),
                              fillColor: Colors.white,
                              elevation: 2,
                              borderColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              borderWidth: 1,
                              borderRadius: 2,
                              margin: EdgeInsetsDirectional.fromSTEB(
                                  12, 12, 12, 12),
                              hidesUnderline: true,
                            ),
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
                            child: FlutterFlowDropDown(
                              options: ['Abyssinian'],
                              onChanged: (val) =>
                                  setState(() => breedValue = val),
                              width: 180,
                              height: 40,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                              hintText: 'Breed',
                              icon: Icon(
                                Icons.merge_type_sharp,
                                size: 15,
                              ),
                              fillColor: Colors.white,
                              elevation: 2,
                              borderColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              borderWidth: 1,
                              borderRadius: 2,
                              margin: EdgeInsetsDirectional.fromSTEB(
                                  12, 12, 12, 12),
                              hidesUnderline: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: weightController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Weight',
                          labelStyle: FlutterFlowTheme.of(context).bodyText2,
                          hintText: 'kg',
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.weight,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: heightController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Shoulder Height',
                          labelStyle: FlutterFlowTheme.of(context).bodyText2,
                          hintText: 'cm',
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.rulerVertical,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: allergiesController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Allergies',
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: FaIcon(
                            FontAwesomeIcons.sith,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                      child: TextFormField(
                        controller: existingConditionsController,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Existing Conditions',
                          hintStyle: FlutterFlowTheme.of(context).bodyText2,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                          suffixIcon: Icon(
                            Icons.sick,
                            color: Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyText1,
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
                child: FFButtonWidget(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  text: 'Save Changes',
                  options: FFButtonOptions(
                    width: 340,
                    height: 60,
                    color: Color(0xFF16820F),
                    textStyle: FlutterFlowTheme.of(context).subtitle2.override(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                    elevation: 2,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: 8,
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
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext, true),
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                  },
                  child: Text(
                    'Delete Pet Info',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodyText1.override(
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
