import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

import '../env.sample.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final String userName;
  const CallPage({Key? key, required this.channelName, required this.userName})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          appId: Env.APP_ID,
          channelName: widget.channelName,
          username: widget.userName),
      agoraEventHandlers:
          AgoraRtcEventHandlers(onLeaveChannel: (connection, state) {
        Navigator.pop(context);
        print('LEAVE CHANNEL!!!!! ');
      }));

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    client.engine.release();
    super.dispose();
  }

  void initAgora() async {
    if (!client.isInitialized) {
      await client.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              body: SafeArea(
            child: Stack(
              children: [
                AgoraVideoViewer(
                  disabledVideoWidget: Container(
                      child: Center(
                          child: Text(
                        'Video disabled',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      )),
                      color: Colors.black,
                      constraints: BoxConstraints.expand()),
                  client: client,
                  layoutType: Layout.grid,
                ),
                AgoraVideoButtons(client: client),
              ],
            ),
          )),
        ),
        onWillPop: () {
          return Future.value(false); // if true allow back else block it
        });
  }
}
