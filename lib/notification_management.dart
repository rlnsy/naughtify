import 'dart:async';
import 'package:flutter/material.dart';
import 'platform_comm.dart';
import 'dart:convert';

class NotificationManager {

  PlatformMethods pMethods;

  List<Notification> _notifications = new List<Notification>();

  NotificationManager(this.pMethods);

  Future<String> fetchNotifications() async {
    String info = await pMethods.fetchNotifications();
    List sessions = json.decode(info);
    for (Map session in sessions) {
      List notifications = session['notifications'];
      for (Map notificationInfo in notifications) {
        var notification = Notification.fromJSON(notificationInfo);
        _notifications.add(notification);
      }
    }
    return info;
  }

  int getNum() {
    return _notifications.length;
  }


  // VIEW STUFF

  Widget _infoState = new Container();

  Widget buildInfo() {
    return new FutureBuilder(
        future: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _infoState = _buildList();
          } else if (snapshot.hasError) {
            return new Text("there was an error getting notification info");
          }
          return _infoState;
        });
  }

  Widget _buildList() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        if (index >= getNum()) {
          return new Container();
        } else {
          return _buildSessionView(_notifications[index]);
        }
      }
    );
  }

  Widget _buildSessionView(Notification n) {
    return new Text('this is single session view');
    // TODO: this
  }
}

// JSON STUFF

class Session {
  final List<Notification> notifications;

  Session(this.notifications);
}

class Notification {
  final String packageName;
  final int timeCode;

  Notification(this.packageName, this.timeCode);

  Notification.fromJSON(Map<String, dynamic> jsonObject)
    : packageName = jsonObject['packagename'],
      timeCode = jsonObject['timecode'];
}
