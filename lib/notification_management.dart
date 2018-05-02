import 'dart:async';
import 'package:flutter/material.dart';
import 'platform_comm.dart';

class NotificationManager {
  PlatformMethods pMethods;

  NotificationManager(this.pMethods);

  Future<String> getNotifications() async {
    return await pMethods.getNotifications();
  }

  int getNum() {
    return 0;
  }


  // VIEW STUFF

  Widget infoState = new Container();

  Widget buildInfo() {
    return new FutureBuilder(
        future: pMethods.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            infoState = new Text(snapshot.data);
          } else if (snapshot.hasError) {
            return new Text("there was an error getting notification info");
          }
          return infoState;
        });
  }
}
