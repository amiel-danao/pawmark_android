import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

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
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(hintText: placeHolder, errorMaxLines: 3),
        validator: textValidator,
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
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(hintText: 'Email', errorMaxLines: 3),
        validator: (value) => EmailValidator.validate(value!)
            ? null
            : "Please enter a valid email",
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
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration:
            const InputDecoration(hintText: 'Password', errorMaxLines: 3),
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 6)
            return "Password must not be empty and not less than 6 characters!";
          else
            return null;
        },
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
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        decoration:
            const InputDecoration(hintText: 'Phone no.', errorMaxLines: 3),
        validator: (value) {
          if (value == null) return null;
          if (value.length != 10)
            return "Mobile Number must be of 10 digit";
          else
            return null;
        },
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
