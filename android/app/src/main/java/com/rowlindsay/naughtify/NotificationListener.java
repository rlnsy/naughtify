package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.Intent;
import android.content.IntentFilter;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

@TargetApi(25)
public class NotificationListener extends NotificationListenerService {

    @Override
    public void onCreate() {
        super.onCreate();
        IntentFilter filter = new IntentFilter();
        filter.addAction("com.rowlindsay.NOTIFICATION_LISTEN");
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        Intent i = new Intent("com.rowlindsay.NOTIFICATION_LISTEN");
        i.putExtra("notification event","notification added");
        sendBroadcast(i);
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        Intent i = new Intent("com.rowlindsay.NOTIFICATION_LISTEN");
        i.putExtra("notification event","notification removed");
        sendBroadcast(i);
    }
}
