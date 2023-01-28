import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';

class NotifWidget extends StatelessWidget {
  NotifWidget({Key? key, required this.counter}) : super(key: key);
  final String counter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      child: Stack(
        children: [
          Icon(
            Icons.notifications,
            size: 30,
          ),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 5),
            child: (counter == '0')
                ? Container()
                : Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffc32c37),
                        border: Border.all(color: Colors.white, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Center(
                        child: Text(
                          counter,
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
