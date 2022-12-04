import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:image/image.dart' as IMG;
import '../env.sample.dart';
import '../models/device.dart';

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

Future<Map<String, Device>> loadMyDevices(
    {String ownerId = "", String petId = ""}) async {
  String baseEndpoint = '${Env.URL_DEVICE_LIST}?';
  final queryParams = Map<String, String>();

  if (ownerId.isNotEmpty) queryParams.putIfAbsent('owner', () => ownerId);
  if (petId.isNotEmpty) queryParams.putIfAbsent('pet', () => petId);

  final uri = Uri.parse(baseEndpoint).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  final items = json.decode(response.body).cast<Map<String, dynamic>>();
  List<Device> devices = items.map<Device>((json) {
    return Device.fromJson(json);
  }).toList();
  var devicesMap = Map<String, Device>();

  try {
    for (var device in devices) {
      devicesMap.putIfAbsent(device.deviceId, () => device);
    }
  } catch (exception) {
    print(exception);
  }

  return devicesMap;
}

Future<String> loadMyDevice(String petId) async {
  Map<String, Device> devices = await loadMyDevices(petId: petId);

  return devices.values.first.deviceId;
}

// Future<BitmapDescriptor> getMarkerIcon(String url, BuildContext context) async {
//   http.Response response = await http.get(
//     Uri.parse('${Env.URL_PREFIX}$url'),
//   );

//   final Uint8List markerIcon = response.bodyBytes;
//   var resizedIcon = resizeImage(markerIcon, context);
//   return BitmapDescriptor.fromBytes(resizedIcon ?? markerIcon);
// }

Uint8List? resizeImage(Uint8List data, BuildContext context) {
  Uint8List? resizedData = data;
  IMG.Image? img = IMG.decodeImage(data);
  var width = (MediaQuery.of(context).size.width * 0.35).toInt();
  // var height = MediaQuery.of(context).size.height * 0.15;
  IMG.Image resized = IMG.copyResize(img!, width: width, height: width);
  resizedData = IMG.encodeJpg(resized) as Uint8List?;
  return resizedData;
}

Future<BitmapDescriptor> getMarkerIcon(String url, Size size) async {
  http.Response response = await http.get(
    Uri.parse('${Env.URL_PREFIX}$url'),
  );

  final Uint8List markerIcon = response.bodyBytes;

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final Radius radius = Radius.circular(size.width / 2);

  final Paint tagPaint = Paint()..color = Colors.blue;
  final double tagWidth = 40.0;

  final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
  final double shadowWidth = 15.0;

  final Paint borderPaint = Paint()..color = Colors.white;
  final double borderWidth = 3.0;

  final double imageOffset = shadowWidth + borderWidth;

  // Add shadow circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      shadowPaint);

  // Add border circle
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(shadowWidth, shadowWidth, size.width - (shadowWidth * 2),
            size.height - (shadowWidth * 2)),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      borderPaint);

  // Add tag circle
  // canvas.drawRRect(
  //     RRect.fromRectAndCorners(
  //       Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
  //       topLeft: radius,
  //       topRight: radius,
  //       bottomLeft: radius,
  //       bottomRight: radius,
  //     ),
  //     tagPaint);

  // Add tag text
  // TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  // textPainter.text = TextSpan(
  //   text: '1',
  //   style: TextStyle(fontSize: 20.0, color: Colors.white),
  // );

  // textPainter.layout();
  // textPainter.paint(
  //     canvas,
  //     Offset(size.width - tagWidth / 2 - textPainter.width / 2,
  //         tagWidth / 2 - textPainter.height / 2));

  // Oval for the image
  Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
      size.width - (imageOffset * 2), size.height - (imageOffset * 2));

  // Add path for oval image
  canvas.clipPath(Path()..addOval(oval));

  // Add image
  ui.Image image = await decodeImageFromList(
      markerIcon); // Alternatively use your own method to get the image
  paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());

  // Convert image to bytes
  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}
