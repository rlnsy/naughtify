package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.service.notification.StatusBarNotification;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

@TargetApi(25)
public class MainActivity extends FlutterActivity {

    private static final String NOTIFICATION_CHANNEL = "com.rowlindsay/notification";

    private NotificationEventReceiver receiver;
    private AndroidNotificationManager manager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), NOTIFICATION_CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        proceessMethodCallFromUI(call,result);
                    }
                }
        );

        manager = new AndroidNotificationManager();

        receiver = new NotificationEventReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction("com.rowlindsay.NOTIFICATION_LISTEN");
        registerReceiver(receiver,filter);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);
    }

    private void proceessMethodCallFromUI(MethodCall call, Result result) {
        if (call.method.equals("clearNotifications")) {
            Intent i = new Intent("com.rowlindsay.UI");
            i.putExtra("uicommand", "clearNotifications");
            sendBroadcast(i);
            result.success("sent clear request to notification service");
        } else if (call.method.equals("getNumNotifications")) {
            int num = manager.getNum();
            result.success(num);
        } else if (call.method.equals("isChannelNeeded")) {
            boolean needed = isChannelNeeded();
            result.success(needed);
        } else {
            result.notImplemented();
        }
    }

    private class NotificationEventReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String eventName = intent.getStringExtra("notification event");
            Log.d("notification", "event receive: " + eventName);

            StatusBarNotification infoGot = intent.getParcelableExtra("notification info");
            if (infoGot != null) {
                manager.add(infoGot);
                Log.d("notification got", infoGot.toString());
                Log.d("notification store", "manager has " + manager.getNum() + " notifications stored");
            }
        }
    }

    // returns true if android version is at or above 8.0 and
    // needs notification channeling
    // note: version code for oreo was not available
    private boolean isChannelNeeded() {
        return Build.VERSION.SDK_INT >= 26;
    }
}
