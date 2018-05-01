import 'package:flutter/services.dart';
import 'package:local_notifications/local_notifications.dart';
import 'dart:async';

class PlatformMethods {

  static const platform = const MethodChannel('com.rowlindsay/notification');

  // TODO: make channel persist for install
  bool hasNotificationChannel = false;
  int _notID = 0;

  static const AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    id: 'test_notification',
    name: 'naughtify-test',
    description: 'grant naughtify the ability to show notifications',
    importance: AndroidNotificationChannelImportance.HIGH,
  );

  Future<bool> _notificationChannelNeeded() async {
    return await platform.invokeMethod("isChannelNeeded");
  }

  _createNotificationChannel() {
    print('creating a new channel');
    LocalNotifications.createAndroidNotificationChannel(channel: _channel);
    hasNotificationChannel = true;
  }

  clearNotifications() async {
    try {
      await platform.invokeMethod('clearNotifications');
    } on PlatformException catch (e) {
      print('could not clear');
    }
  }

  Future<int> getNumNotifications() async {
    int num;
    try {
      num = await platform.invokeMethod('getNumNotifications');
    } on PlatformException catch (e) {
      num = -1;
    }
    return num;
  }

  sendNotification() {
    var channelNeeded = _notificationChannelNeeded();
    channelNeeded.then((isNeeded) {
      if (isNeeded) {
        if (!hasNotificationChannel) {
          _createNotificationChannel();
        }
        LocalNotifications.createNotification(
            title: "Testing...", content: "This is just a test notification", id: _notID,
            androidSettings: new AndroidSettings(channel: _channel));
      } else {
        LocalNotifications.createNotification(
            title: "Basic", content: "Notification", id: _notID);
      }
        _notID++;
    });
  }

  toggleMuteMode() {
    platform.invokeMethod("toggleMuteMode");
  }
}