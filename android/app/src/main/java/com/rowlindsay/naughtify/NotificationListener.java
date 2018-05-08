package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

@TargetApi(25)
public class NotificationListener extends NotificationListenerService {

    @Override
    public void onCreate() {
        super.onCreate();
        UIActionReceiver actionReceiver = new UIActionReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction("com.rowlindsay.UI");
        registerReceiver(actionReceiver,filter);
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        Intent i = new Intent("com.rowlindsay.NOTIFICATION_LISTEN");
        i.putExtra("type","listener event");
        i.putExtra("notification event","notification added");
        sendBroadcast(i);

        Intent notificationSend = new Intent("com.rowlindsay.NOTIFICATION_LISTEN");

        // INFORMATION
        notificationSend.putExtra("type","information");
        notificationSend.putExtra("packagename",sbn.getPackageName());
        notificationSend.putExtra("timecode",sbn.getPostTime());
        notificationSend.putExtra("title",sbn.getNotification().extras.getString("android.title"));
        notificationSend.putExtra("text",sbn.getNotification().extras.getCharSequence("android.text").toString());
        notificationSend.putExtra("rawinfo",sbn.toString());

        sendBroadcast(notificationSend);
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        Intent i = new Intent("com.rowlindsay.NOTIFICATION_LISTEN");
        i.putExtra("type","listener event");
        i.putExtra("notification event","notification removed");
        sendBroadcast(i);
    }

    class UIActionReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getStringExtra("uicommand").equals("clearNotifications")) {
                NotificationListener.this.cancelAllNotifications();
            }
        }
    }
}
