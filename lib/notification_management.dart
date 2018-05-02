import 'dart:async';
import 'platform_comm.dart';
import 'dart:convert';
import 'dart:math';


class NotificationManager {

  PlatformMethods pMethods;

  List<Session> _sessions = new List<Session>();

  NotificationManager(this.pMethods);

  //TODO: test for jank and maybe move to separate isolate

  Future<String> fetchNotifications() async {
    String info = await pMethods.fetchNotifications();
    List sessions = json.decode(info);
    for (Map sessionInfo in sessions) {
      Session session = new Session();
      List notifications = sessionInfo['notifications'];
      for (Map notificationInfo in notifications) {
        var notification = NotificationEntry.fromJSON(notificationInfo);
        if (!_contains(notification))
          session.add(notification);
      }
      if (session.length() > 0)
        _addSession(session);
    }
    return info;
  }

  _addSession(Session s) {
    int newerSessions = 0;
    for (Session other in _sessions) {
      if (other.newerThan(s))
        newerSessions++;
    }
    _sessions.insert(newerSessions, s);
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

  bool _contains(NotificationEntry n) {
    for (Session s in _sessions) {
      if (s.contains(n))
        return true;
    }
    return false;
  }

}

// JSON STUFF

class Session {
  final List<NotificationEntry> notifications = new List<NotificationEntry>();

  int newest = 0;

  add(NotificationEntry n) {
    int newer = 0;
    for (NotificationEntry other in notifications) {
      if (other.timeCode > n.timeCode)
        newer++;
    }
    notifications.insert(newer, n);
    if (newer == 0)
      newest = n.timeCode;
  }

  bool contains(NotificationEntry n) {
    return notifications.contains(n);
  }

  int length() {
    return notifications.length;
  }

  bool newerThan(Session other) {
    return newest > other.newest;
  }
}

class NotificationEntry {
  final String packageName;
  final int timeCode;

  NotificationEntry(this.packageName, this.timeCode);

  NotificationEntry.fromJSON(Map<String, dynamic> jsonObject)
    : packageName = jsonObject['packagename'],
      timeCode = jsonObject['timecode'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NotificationEntry &&
              runtimeType == other.runtimeType &&
              packageName == other.packageName &&
              timeCode == other.timeCode && pow((other.timeCode - timeCode),2) <= 100; // Filter out close notifs

  @override
  int get hashCode =>
      packageName.hashCode ^
      timeCode.hashCode;
}
