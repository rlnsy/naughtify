import 'package:flutter/services.dart';
import 'package:local_notifications/local_notifications.dart';
import 'dart:async';

class PlatformMethods {
  static const platform =
      const MethodChannel('com.rowlindsay/platform-methods');

  // TODO: make channel persist for install
  bool hasNotificationChannel = false;
  int _notID = 0;

  static const AndroidNotificationChannel _channel =
      const AndroidNotificationChannel(
    id: 'test_notification',
    name: 'naughtify-test',
    description: 'grant naughtify the ability to send test notifications',
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

  Future<String> fetchNotifications() async {
    try {
      return await platform.invokeMethod('getNotifications');
    } on PlatformException catch (e) {
      return "error getting notifications";
    }
  }

  Future<bool> platformIsAndroid() {
    return platform.invokeMethod("isAndroid");
  }

  // no-op on ios // TEMPORARILY DISABLED
  sendNotification() {
    var channelNeeded = _notificationChannelNeeded();
    channelNeeded.then((isNeeded) {
      if (isNeeded) {
        if (!hasNotificationChannel) {
          _createNotificationChannel();
        }
        LocalNotifications.createNotification(
            title: "Testing: 1,2,3...",
            content: "(this is just a test notification)",
            id: _notID,
            androidSettings: new AndroidSettings(channel: _channel));
      } else {
        LocalNotifications.createNotification(
            title: "Testing: 1,2,3...", content: "(this is just a test notification)", id: _notID);
      }
      _notID++;
    });
  }

  toggleMuteMode() {
    platform.invokeMethod("toggleMuteMode");
  }
}
