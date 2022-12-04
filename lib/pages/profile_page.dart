import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auth_service/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/constants/app_constants.dart';
import 'package:flutter_chat_demo/constants/constants.dart';
import 'package:flutter_chat_demo/providers/providers.dart';
import 'package:flutter_chat_demo/widgets/loading_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../api/pet_controller.dart';
import '../env.sample.dart';
import '../widgets/profile_widgets.dart';
import 'chat_list_page.dart';

class ProfilePage extends StatelessWidget {
  final Customer currentCustomer;
  ProfilePage({Key? key, required this.currentCustomer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          AppConstants.profileTitle,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ProfilePageState(currentCustomer: currentCustomer),
    );
  }
}

class ProfilePageState extends StatefulWidget {
  final Customer currentCustomer;
  ProfilePageState({Key? key, required this.currentCustomer}) : super(key: key);

  @override
  State createState() => ProfilePageStateState();
}

class ProfilePageStateState extends State<ProfilePageState> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileController;

  String photoUrl = '';
  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    String? picture = widget.currentCustomer.picture;
    photoUrl = picture!;

    _emailController =
        TextEditingController(text: widget.currentCustomer.email);
    _firstNameController =
        TextEditingController(text: widget.currentCustomer.firstName);
    _middleNameController =
        TextEditingController(text: widget.currentCustomer.middleName);
    _lastNameController =
        TextEditingController(text: widget.currentCustomer.lastName);
    _mobileController =
        TextEditingController(text: widget.currentCustomer.mobile);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _emailController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void handleUpdateData() async {
    setState(() {
      isLoading = true;
    });

    String uid = widget.currentCustomer.id;
    Customer updatedCustomer = new Customer(
        id: uid,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        middleName: _middleNameController.text,
        mobile: _mobileController.text);

    final jsonData = jsonEncode(updatedCustomer.toJson());

    try {
      final patchResponse = await http.patch(
        Uri.parse('${Env.URL_CUSTOMER}/${widget.currentCustomer.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (patchResponse.statusCode == 200) {
        Fluttertoast.showToast(msg: "Update success");
        setState(() {
          isLoading = false;
        });

        updatedCustomer = Customer.fromJson(jsonDecode(patchResponse.body));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatListPage(currentCustomer: updatedCustomer)));
      }

      print("Update failed : ${patchResponse.body.toString()}");
    } catch (exception) {
      print("Update failed : ${exception.toString()}");
      Fluttertoast.showToast(msg: "Update failed : ${exception.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Avatar
                  CupertinoButton(
                    onPressed: () {},
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: avatarImageFile == null
                          ? photoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(45),
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                    errorBuilder:
                                        (context, object, stackTrace) {
                                      return Icon(
                                        Icons.account_circle,
                                        size: 90,
                                        color: ColorConstants.greyColor,
                                      );
                                    },
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: ColorConstants.greyColor,
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.file(
                                avatarImageFile!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        uploadImage(
                            '${Env.URL_CUSTOMER_IMAGE}/${widget.currentCustomer.id}',
                            'picture',
                            {'id': widget.currentCustomer.id},
                            context,
                            (value) => setState(() {
                                  photoUrl = value;
                                }));
                      },
                      child: Text('Change Photo')),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 30.0),
                        ProfileAccountName(
                          controller: _firstNameController,
                          placeHolder: 'First name',
                          textValidator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length == 0)
                              return "Please input First name";
                            else
                              return null;
                          },
                        ),
                        const SizedBox(height: 30.0),
                        ProfileAccountName(
                          controller: _middleNameController,
                          placeHolder: 'Middle name',
                        ),
                        const SizedBox(height: 30.0),
                        ProfileAccountName(
                          controller: _lastNameController,
                          placeHolder: 'Last name',
                          textValidator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length == 0)
                              return "Please input Last name";
                            else
                              return null;
                          },
                        ),
                        const SizedBox(height: 30.0),
                        ProfileAccountEmail(emailController: _emailController),
                        const SizedBox(height: 30.0),
                        ProfileAccountPhone(phoneController: _mobileController),
                        const SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleUpdateData();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Invalid profile input!"),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            ColorConstants.primaryColor),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.fromLTRB(30, 10, 30, 10),
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(top: 50, bottom: 50),
                  ),
                ],
              ),
            )),

        // Loading
        Positioned(child: isLoading ? LoadingView() : SizedBox.shrink()),
      ],
    );
  }
}
