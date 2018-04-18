package com.rowlindsay.naughtify;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String NOTIFICATION_CHANNEL = "com.rowlindsay/notification";

    private NotificationEventReceiver receiver;

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

        receiver = new NotificationEventReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction("com.rowlindsay.NOTIFICATION_LISTEN");
        registerReceiver(receiver,filter);
    }

    private void proceessMethodCallFromUI(MethodCall call, Result result) {
        if (call.method.equals("clearNotifications")) {
            Intent i = new Intent("com.rowlindsay.UI");
            i.putExtra("uicommand","clearNotifications");
            sendBroadcast(i);
            result.success("sent clear request to notification service");
        } else {
            result.notImplemented();
        }
    }

    class NotificationEventReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String eventName = intent.getStringExtra("notification event");
            Log.d("notification", "event receive: " + eventName);
        }
    }
}
