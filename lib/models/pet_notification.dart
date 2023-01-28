import 'package:cloud_firestore/cloud_firestore.dart';

class PetNotification {
  final String? title;
  final String? message;

  PetNotification({this.title, this.message});

  factory PetNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PetNotification(
      title: data?['title'],
      message: data?['message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (message != null) "message": message,
    };
  }
}
