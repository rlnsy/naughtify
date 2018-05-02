import 'dart:async';
import 'package:flutter/material.dart';
import 'platform_comm.dart';
import 'dart:convert';

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
        var notification = Notification.fromJSON(notificationInfo);
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
        if (index >= getNumSessions()) {
          return new Container();
        } else {
          return _buildSessionView(_sessions[index]);
        }
      }
    );
  }

  Widget _buildSessionView(Session s) {
    return new Column(
      children:_buildNotificationViews(s),
    );
  }

  List<Widget> _buildNotificationViews(Session s) {
    List<Widget> views = new List<Widget>();
    for (Notification n in s.notifications) {
      views.add(_buildNotificationView(n));
    }
    return views;
  }

  Widget _buildNotificationView(Notification n) {
    return new Text('${n.timeCode} - ${n.packageName}');
  }

}

// JSON STUFF

class Session {
  final List<Notification> notifications = new List<Notification>();  

  add(Notification n) {
    notifications.add(n);
  }
}

class Notification {
  final String packageName;
  final int timeCode;

  Notification(this.packageName, this.timeCode);

  Notification.fromJSON(Map<String, dynamic> jsonObject)
    : packageName = jsonObject['packagename'],
      timeCode = jsonObject['timecode'];
}
