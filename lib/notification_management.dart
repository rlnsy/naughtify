import 'dart:async';
import 'platform_comm.dart';

class NotificationManager {
  PlatformMethods pMethods;

  NotificationManager(this.pMethods);

  Future<String> getNotifications() async {
    return await pMethods.getNotifications();
  }

}