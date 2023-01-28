import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/color_constants.dart';
import '../env.sample.dart';
import '../models/immunization_history.dart';
import '../themes/flutter_flow_theme.dart';

class VaccineDetailsPageWidget extends StatefulWidget {
  final ImmunizationHistory vaccineRecord;
  const VaccineDetailsPageWidget({Key? key, required this.vaccineRecord})
      : super(key: key);
  @override
  _VaccineDetailsPageWidgetState createState() =>
      _VaccineDetailsPageWidgetState();
}

class _VaccineDetailsPageWidgetState extends State<VaccineDetailsPageWidget> {
  final _unfocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: ColorConstants.primaryColor,
          title: Text(
            'Vaccination Record',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          centerTitle: false,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vaccination Record',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                      child: Text(
                        "${DateFormat.yMMMMd().format(widget.vaccineRecord.date)} ${DateFormat('hh:mm').format(widget.vaccineRecord.date)}",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: Text(
                        'Owner Actions:',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                      child: Text(
                        widget.vaccineRecord.ownerActions,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: Text(
                        'Veterinarian Actions:',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                      child: Text(
                        widget.vaccineRecord.veterinaryActions,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                      child: Text(
                        widget.vaccineRecord.attachment.isEmpty
                            ? 'No attachment'
                            : 'Attachment',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.vaccineRecord.attachment.isEmpty
                            ? Image.asset(
                                'images/no_image.png',
                                width: MediaQuery.of(context).size.width / 2,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                '${Env.URL_PREFIX}${widget.vaccineRecord.attachment}',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
