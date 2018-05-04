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

  // TODO: clean up whole class

  NotificationManager(this.pMethods,this.storage) {
    // temporary:
    // TODO: find a place to write data
    storage.writeInfo('[{"starttime": "1", "endtime": "2", "notifications": [{"timecode": 3,"packagename": "com.test"}]}]');
  }

  bool _isLoaded = false;

  bool notLoaded() {
    return !_isLoaded;
  }

  //TODO: test for jank and maybe move to separate isolate

  Future<String> decodeNewNotifications() async {
    String info = await pMethods.fetchNotifications();
    _decode(info);
    //await writeToFile();
    return info;
  }

  Future<String> decodeFromFile() async {
    if (!_isLoaded) {
      print('decoding history from file...');
      String info = await storage.readInfo();
      print('info read from file: $info');
      try {
        _decode(info);
      } catch (e) {
        print('file decode: $e');
        print(info);
      }
      _isLoaded = true;
      return info;
    } else {
      return 'already loaded';
    }
  }

  Future<File> writeToFile() async {
    print('writing to file...');
    String encodedInfo = '[${_encodeSessions()}]';
    print('encoded info: ${encodedInfo}');
    return await storage.writeInfo(encodedInfo);
  }

  String _encodeSessions({int index = 0}) {
    print(' - encoding sessions');
    if (index >= _sessions.length) {
      return "";
    } else if (index >= 1) {
      return ',${encodeSession(_sessions[index])}' + _encodeSessions(index: index+1);
    } else {
      return '${encodeSession(_sessions[index])}' + _encodeSessions(index: index+1);
    }
  }

  String encodeSession(Session s) {
    print(' - - session encode');
    return '{"starttime": "${s.getStartTime()}","endtime": "${s.getEndTime()}","notifications": [${_encodeNotifications(s)}]}';
  }

  String _encodeNotifications(Session s, {int index = 0}) {
    List<NotificationEntry> notifications = s.getNotifications();
    if (index >= notifications.length) {
      return "";
    } else if (index >= 1) {
      return ',${_encodeNotification(notifications[index])}' + _encodeNotifications(s, index: index + 1);
    } else {
      return '${_encodeNotification(notifications[index])}' + _encodeNotifications(s, index: index + 1);
    }
  }

  String _encodeNotification(NotificationEntry n) {
    return '{"timecode": ${n.timeCode},"packagename": "${n.packageName}"}';
  }

  _decode(String info) {
    List sessions;
    sessions = json.decode(info);
    print("decode: ${sessions.length} sessions found");
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
      num += s.getNotifications().length;
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

  List<NotificationEntry> _notifications;

  int newest = 0;

  String start, end;

  Session(this.start,this.end) {
    _notifications = new List<NotificationEntry>();
  }

  add(NotificationEntry n) {
    int newer = 0;
    for (NotificationEntry other in _notifications) {
      if (other.timeCode > n.timeCode)
        newer++;
    }
    _notifications.insert(newer, n);
    if (newer == 0)
      newest = n.timeCode;
  }

  bool contains(NotificationEntry n) {
    return _notifications.contains(n);
  }

  int length() {
    return _notifications.length;
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

  List<NotificationEntry> getNotifications() {
    return _notifications;
  }
}

class NotificationEntry {

  String packageName;
  int timeCode;

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
    //final directory = await Directory.systemTemp.createTemp();
    return  directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/sessions.json');
  }

  Future<String> readInfo() async {
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e) {
      print('error reading history file : $e');
      return '[]';
    }
  }

  Future<File> writeInfo(String info) async {
    final file = await _localFile;


    // TODO: encode


    // Write the file
    print('file write: info = $info');
    var testFile = await file.writeAsString(info);
    print('file test: contents = ${await testFile.readAsString()}');
    return testFile;
  }
}
