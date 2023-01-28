import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:auth_service/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/constants/app_constants.dart';
import 'package:flutter_chat_demo/constants/constants.dart';
import 'package:flutter_chat_demo/models/veterinarian.dart';
import 'package:flutter_chat_demo/providers/providers.dart';
import 'package:flutter_chat_demo/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

import '../api/common.dart';
import '../api/customer_controller.dart';
import '../env.sample.dart';
import '../login/view/login_view.dart';
import '../models/models.dart';
import '../models/pet_notification.dart';
import '../widgets/widgets.dart';
import 'pages.dart';
import 'package:http/http.dart' as http;
import 'my_nav_drawer.dart';

class NotificationPage extends StatefulWidget {
  final Customer currentCustomer;

  NotificationPage({Key? key, required this.currentCustomer}) : super(key: key);

  @override
  State createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  NotificationPageState({Key? key});
  final veterinarianListKey = GlobalKey<NotificationPageState>();

  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();
  late Future<List<Veterinarian>> veterinarians;
  late String? fcmToken;

  @override
  void initState() {
    super.initState();

    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    veterinarians = getVeterinarianList();

    if (authProvider.firebaseAuth.currentUser?.uid.isNotEmpty == true) {
      currentUserId = authProvider.firebaseAuth.currentUser!.uid;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginView()),
        (Route<dynamic> route) => false,
      );
    }

    // configLocalNotification();
    listScrollController.addListener(scrollListener);
  }

  void saveFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      fcmToken = token;
      print('fcmToken: $fcmToken');
    });
  }

  void askFirebaseMessagingPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<List<Veterinarian>> getVeterinarianList() async {
    final Uri uri = Uri.parse(Env.URL_VETERINARY_LIST);
    final response = await http.get(uri);

    final items = json.decode(response.body).cast<Map<String, dynamic>>();
    List<Veterinarian> veterinarians = items.map<Veterinarian>((json) {
      return Veterinarian.fromJson(json);
    }).toList();

    return veterinarians;
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  // Future<void> handleSignOut() async {
  //   authProvider.handleSignOut();
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (context) => LoginView()),
  //     (Route<dynamic> route) => false,
  //   );
  // }

  Future<QuerySnapshot<PetNotification>> recipeData() async {
    var snapshots = FirebaseFirestore.instance
        .collection("notifications")
        .where("user_id", isEqualTo: authProvider.firebaseAuth.currentUser?.uid)
        .withConverter<PetNotification>(
          fromFirestore: (doc, opts) =>
              PetNotification.fromFirestore(doc, opts),
          toFirestore: (data, _) => data.toFirestore(),
        )
        .get();

    // Get a new write batch
    final batch = FirebaseFirestore.instance.batch();
    // snapshots.forEach((document) {
    await snapshots.asStream().forEach((snapshot) {
      snapshot.docs.forEach((element) {
        var nycRef = FirebaseFirestore.instance
            .collection("notifications")
            .doc(element.id);
        batch.set(nycRef, {"read": "yes"}, SetOptions(merge: true));
      });
    });
    // });

    // Commit the batch
    await batch.commit();
    // .then((_) {

    // });

    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackPress,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: Colors.green[700],
          ),
          drawer: MyNavDrawer(
            counter: 0,
            currentCustomer: widget.currentCustomer,
            signOutFunction: () {
              handleSignOut(context, authProvider);
            },
          ),
          body: FutureBuilder<QuerySnapshot<PetNotification>>(
              future: recipeData(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<PetNotification>> snapshot) {
                if (snapshot.hasError) return Text('Something went wrong');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data!.docs[index]['title']),
                      subtitle: Text(snapshot.data!.docs[index]['message']),
                    );
                  },
                );
              }),

          // StreamBuilder<QuerySnapshot<PetNotification>>(
          //     stream: recipeData,
          //     builder: (context,
          //         AsyncSnapshot<QuerySnapshot<PetNotification>> snapshot) {
          //       if (snapshot.hasError) return Text('Something went wrong');
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return CircularProgressIndicator();
          //       }

          //       return ListView.builder(
          //         itemCount: snapshot.data!.docs.length,
          //         itemBuilder: (context, index) {
          //           return ListTile(
          //             title: Text(snapshot.data!.docs[index]['title']),
          //             subtitle: Text(snapshot.data!.docs[index]['message']),
          //           );
          //         },
          //       );
          //     }),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  Future<bool> onBackPress() {
    openDialog(context);
    return Future.value(false);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }
}
