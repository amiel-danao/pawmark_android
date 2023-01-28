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
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../api/common.dart';
import '../api/customer_controller.dart';
import '../env.sample.dart';
import '../login/view/login_view.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'notification_page.dart';
import 'pages.dart';
import 'package:http/http.dart' as http;
import 'my_nav_drawer.dart';

class ChatListPage extends StatefulWidget {
  final Customer currentCustomer;

  ChatListPage({Key? key, required this.currentCustomer}) : super(key: key);

  @override
  State createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  ChatListPageState({Key? key});
  final veterinarianListKey = GlobalKey<ChatListPageState>();

  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;
  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> btnClearController = StreamController<bool>();
  TextEditingController searchBarTec = TextEditingController();
  late Future<List<Veterinarian>> veterinarians;
  int counter = 0;

  @override
  void initState() {
    super.initState();

    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    veterinarians = getVeterinarianList();

    if (authProvider.firebaseAuth.currentUser?.uid.isNotEmpty == true &&
        authProvider.firebaseAuth.currentUser!.emailVerified == true) {
      currentUserId = authProvider.firebaseAuth.currentUser!.uid;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginView()),
        (Route<dynamic> route) => false,
      );
    }

    checkDeviceTokenRecord();
    // configLocalNotification();
    listScrollController.addListener(scrollListener);
    askFirebaseMessagingPermission();

    listenToNotifications(
        authProvider.firebaseAuth.currentUser?.uid,
        () => setState(() {
              counter++;
            }));
  }

  Future<void> checkDeviceTokenRecord() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await createDeviceToken(token!, authProvider.firebaseAuth.currentUser!.uid);
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

  Widget buildNotificationBell() {
    return new Stack(
      children: <Widget>[
        new IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              setState(() {
                counter = 0;
              });

              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationPage(
                          currentCustomer: widget.currentCustomer)));
            }),
        counter != 0
            ? new Positioned(
                right: 11,
                top: 11,
                child: new Container(
                  padding: EdgeInsets.all(2),
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$counter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : new Container()
      ],
    );
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  Future<void> handleSignOut() async {
    authProvider.handleSignOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginView()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: veterinarianListKey,
      drawer: MyNavDrawer(
        counter: counter,
        currentCustomer: widget.currentCustomer,
        signOutFunction: () {
          handleSignOut();
        },
      ),
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: Text(
          AppConstants.chatListTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[buildNotificationBell()],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                // buildSearchBar(),
                Expanded(
                  child: FutureBuilder<List<Veterinarian>>(
                    future: veterinarians,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // By default, show a loading spinner.
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                          ),
                        );
                      } else {
                        if (snapshot.data.length > 0) {
                          // Render employee lists
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) =>
                                  buildItem(context, snapshot.data[index]),
                              controller: listScrollController);
                        } else {
                          return Center(
                            child: Text("No veterinarians available"),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            // Loading
            Positioned(
              child: isLoading ? LoadingView() : SizedBox.shrink(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    btnClearController.close();
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings();
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    }
  }

  Future<bool> onBackPress() {
    openDialog(context);
    return Future.value(false);
  }

  Widget buildSearchBar() {
    return Container(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search, color: ColorConstants.greyColor, size: 20),
          SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTec,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    btnClearController.add(true);
                    setState(() {
                      _textSearch = value;
                    });
                  } else {
                    btnClearController.add(false);
                    setState(() {
                      _textSearch = "";
                    });
                  }
                });
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Search veterinarian name',
                hintStyle:
                    TextStyle(fontSize: 13, color: ColorConstants.greyColor),
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder<bool>(
              stream: btnClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          searchBarTec.clear();
                          btnClearController.add(false);
                          setState(() {
                            _textSearch = "";
                          });
                        },
                        child: Icon(Icons.clear_rounded,
                            color: ColorConstants.greyColor, size: 20))
                    : SizedBox.shrink();
              }),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ColorConstants.greyColor2,
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
    );
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorConstants.primaryColor,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: TextStyle(color: ColorConstants.primaryColor),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }

  Widget buildItem(BuildContext context, Veterinarian? veterinarian) {
    if (veterinarian != null) {
      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              Material(
                child: veterinarian.picture.isNotEmpty
                    ? Image.network(
                        '${Env.URL_PREFIX}${veterinarian.picture}',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorConstants.themeColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 50,
                            color: ColorConstants.greyColor,
                          );
                        },
                      )
                    : Image.asset(
                        'images/doc1.jpg',
                        width: 50,
                        height: 50,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          veterinarian.firstname.isEmpty &&
                                  veterinarian.lastname.isEmpty
                              ? 'Email: ${veterinarian.email}'
                              : 'Name: ${veterinarian.firstname} ${veterinarian.lastname}',
                          maxLines: 1,
                          style: TextStyle(color: ColorConstants.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      ),
                      Container(
                        child: Text(
                          'About me: ${veterinarian.aboutMe}',
                          maxLines: 1,
                          style: TextStyle(color: ColorConstants.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20),
                ),
              ),
            ],
          ),
          onPressed: () {
            if (Utilities.isKeyboardShowing()) {
              Utilities.closeKeyboard(context);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  arguments: ChatPageArguments(
                    peerId: veterinarian.id,
                    peerAvatar: '${Env.URL_PREFIX}${veterinarian.picture}',
                    peerNickname: veterinarian.firstname.isEmpty &&
                            veterinarian.lastname.isEmpty
                        ? veterinarian.email
                        : '${veterinarian.firstname} ${veterinarian.lastname}',
                  ),
                ),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(ColorConstants.greyColor2),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
