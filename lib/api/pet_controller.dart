import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../env.sample.dart';

void loadPetImage(String petId, void Function(String) func) async {
  Uri uri = Uri.parse('${Env.URL_PET_IMAGE}/$petId');
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final result = json.decode(response.body);
    func(result['image'] == null ? '' : result['image']);
  }
}

void uploadImage(
    String url,
    String imageFieldKey,
    Map<String, String> additionalFields,
    BuildContext context,
    void Function(String) func) async {
  final ImagePicker _picker = ImagePicker();
  // Pick an image
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //TO convert Xfile into file
  File file = File(image!.path);
  //print(‘Image picked’);
  var request = http.MultipartRequest('PUT', Uri.parse(url));
  request.fields.addAll(additionalFields);
  request.files.add(http.MultipartFile.fromBytes(
      imageFieldKey, File(file.path).readAsBytesSync(),
      filename: file.path));
  var response = await request.send();
  if (response.statusCode == 200) {
    var responseFromStream = await http.Response.fromStream(response);

    final jsonResponse = json.decode(responseFromStream.body);
    if (jsonResponse[imageFieldKey] != null) {
      func(jsonResponse[imageFieldKey]);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error uploading image ${response.reasonPhrase}'),
      ),
    );
  }
}
