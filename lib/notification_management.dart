import 'dart:async';
import 'platform_comm.dart';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class NotificationManager {

  PlatformMethods pMethods;
  NotificationStorage storage;

  List<Session> _sessions = new List<Session>();

  NotificationManager(this.pMethods,this.storage);

  //TODO: test for jank and maybe move to separate isolate

  Future<String> decodeNewNotifications() async {
    String info = await pMethods.fetchNotifications();
    _decode(info);
    writeToFile();
    return info;
  }

  Future<String> decodeFromFile() async {
    String info = await storage.readInfo();
    try {
      _decode(info);
    } catch (e) {
      print("error because file not valid yet");
    }
  }

  Future<File> writeToFile() async {
    return storage.writeInfo('[]');
  }

  String _encode() {

  }

  _decode(String info) {
    List sessions = json.decode(info);
    for (Map sessionInfo in sessions) {
      Session session = new Session(sessionInfo["starttime"],sessionInfo["endtime"]);
      List notifications = sessionInfo['notifications'];
      for (Map notificationInfo in notifications) {
        var notification = NotificationEntry.fromJSON(notificationInfo);
        if (!_contains(notification))
          session.add(notification);
      }
      if (session.length() > 0)
        _addSession(session);
    }
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

  String start, end;

  Session(this.start,this.end);

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

  String getStartTime() {
    return start;
  }

  String getEndTime() {
    return end;
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
              sqrt(pow((other.timeCode - timeCode),2)) < 100; // Filter out close notifs
              //TODO: fix this

  @override
  int get hashCode =>
      packageName.hashCode ^
      timeCode.hashCode;
}

class NotificationStorage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/sessions.txt');
  }

  Future<String> readInfo() async {
    try {
      final file = await _localFile;
      return file.readAsString();
    } catch (e) {
      return 'error reading file';
    }
  }

  Future<File> writeInfo(String info) async {
    final file = await _localFile;


    // TODO: encode


    // Write the file
    return file.writeAsString(info);
  }
}
