import 'dart:async';
import 'package:flutter/material.dart';
import 'platform_comm.dart';
import 'dart:convert';
import 'main.dart';

class NotificationManager {


  PlatformMethods pMethods;

  List<Session> _sessions = new List<Session>();

  NotificationManager(this.pMethods);

  Future<String> fetchNotifications() async {
    String info = await pMethods.fetchNotifications();
    List sessions = json.decode(info);
    for (Map sessionInfo in sessions) {
      Session session = new Session();
      List notifications = sessionInfo['notifications'];
      for (Map notificationInfo in notifications) {
        var notification = NotificationInfo.fromJSON(notificationInfo);
        session.add(notification);
        // TODO: sort duplicates and by time code
      }
      _sessions.add(session);
    }
    return info;
  }

  int getNumNotifications() {
    int num = 0;
    for (Session s in _sessions) {
      num += s.notifications.length;
    }
    return num;
  }

  int getNumSessions() {
    return _sessions.length;
  }

  List<Session> getSessions() {
    return _sessions;
  }

}

// JSON STUFF

class Session {
  final List<NotificationInfo> notifications = new List<NotificationInfo>();

  add(NotificationInfo n) {
    notifications.add(n);
  }
}

class NotificationInfo {
  final String packageName;
  final int timeCode;

  NotificationInfo(this.packageName, this.timeCode);

  NotificationInfo.fromJSON(Map<String, dynamic> jsonObject)
    : packageName = jsonObject['packagename'],
      timeCode = jsonObject['timecode'];
}
