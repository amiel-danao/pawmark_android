import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/value_constants.dart';

class ProfileAccountName extends StatelessWidget {
  ProfileAccountName(
      {Key? key,
      required this.controller,
      required this.placeHolder,
      this.textValidator})
      : super(key: key);
  final TextEditingController controller;
  final String placeHolder;
  final String? Function(String?)? textValidator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / INPUT_FIELD_DIVIDER,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.name,
          validator: textValidator,
          obscureText: false,
          decoration: InputDecoration(
            errorMaxLines: 3,
            labelText: placeHolder,
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
            contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
            suffixIcon: Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF757575),
              size: 22,
            ),
          ),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}

class ProfileAccountEmail extends StatelessWidget {
  ProfileAccountEmail({
    Key? key,
    required this.emailController,
  }) : super(key: key);
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / INPUT_FIELD_DIVIDER,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
        child: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => EmailValidator.validate(value!)
              ? null
              : "Please enter a valid email",
          obscureText: false,
          decoration: InputDecoration(
            errorMaxLines: 3,
            labelText: 'Email',
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
            contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
            suffixIcon: Icon(
              Icons.email,
              color: Color(0xFF757575),
              size: 22,
            ),
          ),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}

class ProfileAccountPassword extends StatelessWidget {
  ProfileAccountPassword({
    Key? key,
    required this.passwordController,
  }) : super(key: key);
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / INPUT_FIELD_DIVIDER,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
        child: TextFormField(
          controller: passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6)
              return "Password must not be empty and not less than 6 characters!";
            else
              return null;
          },
          decoration: InputDecoration(
            errorMaxLines: 3,
            labelText: 'Password',
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
            contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
            suffixIcon: Icon(
              Icons.password,
              color: Color(0xFF757575),
              size: 22,
            ),
          ),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}

class ProfileAccountPhone extends StatelessWidget {
  ProfileAccountPhone({
    Key? key,
    required this.phoneController,
  }) : super(key: key);
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / INPUT_FIELD_DIVIDER,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
        child: TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null) return null;
            if (value.length != 10)
              return "Mobile Number must be of 10 digit";
            else
              return null;
          },
          decoration: InputDecoration(
            errorMaxLines: 3,
            labelText: 'Phone no.',
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
            contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
            suffixIcon: Icon(
              Icons.phone,
              color: Color(0xFF757575),
              size: 22,
            ),
          ),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}

class ProfileAccountLabel extends StatelessWidget {
  ProfileAccountLabel({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: Text(
        label,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor),
      ),
    );
  }
}
