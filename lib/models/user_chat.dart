import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_demo/constants/constants.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String isDoctor;

  UserChat(
      {required this.id,
      required this.photoUrl,
      required this.nickname,
      required this.aboutMe,
      required this.isDoctor});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.isDoctor: isDoctor
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String isDoctor = "";
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      isDoctor = doc.get(FirestoreConstants.isDoctor);
    } catch (e) {}

    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    return UserChat(
        id: doc.id,
        photoUrl: "",
        nickname: nickname,
        aboutMe: aboutMe,
        isDoctor: isDoctor);
  }
}
