package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
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

    // client state information
    private AndroidNotificationManager manager;
    private AndroidNotificationEncoder encoder;
    private boolean muteMode = false;

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
        encoder = new AndroidNotificationEncoder();

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
            clearNotifications();
            result.success("sent clear request to notification service");
        } else if (call.method.equals("getNumNotifications")) {
            int num = manager.getNum();
            result.success(num);
        } else if (call.method.equals("isChannelNeeded")) {
            boolean needed = isChannelNeeded();
            result.success(needed);
        } else if (call.method.equals("toggleMuteMode")) {
            toggleMuteMode();
            result.success(muteMode);
        } else if (call.method.equals("getNotifications")) {
            result.success(encoder.getHistory());
        } else {
            result.notImplemented();
        }
    }

    private class NotificationEventReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String eventName = intent.getStringExtra("notification event");
            if (eventName == null) {
                eventName = "unrecognized notification event";
            }

            Log.d("notification", "event receive: " + eventName);

            StatusBarNotification infoGot = intent.getParcelableExtra("notification info");
            if (infoGot != null) {
                manager.add(infoGot);
                encoder.encode(infoGot);

                Log.d("notification got", infoGot.toString());
                Log.d("notification store", "manager has " + manager.getNum() + " notifications stored");
            }

            if (eventName.equals("notification added") && muteMode) {
                clearNotifications();
            }
        }
    }

    private void toggleMuteMode() {
        muteMode = !muteMode;
        AudioManager audio = (AudioManager) getSystemService(AUDIO_SERVICE);
        if (muteMode) {
            audio.setRingerMode(AudioManager.RINGER_MODE_VIBRATE);
            // TODO: figure out how this works with vibrate on silent
        } else {
            ((AudioManager) getSystemService(AUDIO_SERVICE)).setRingerMode(AudioManager.RINGER_MODE_NORMAL);
            // TODO: retain user's original setting
        }
    }

    private void clearNotifications() {
        Intent i = new Intent("com.rowlindsay.UI");
        i.putExtra("uicommand", "clearNotifications");
        sendBroadcast(i);
    }

    // returns true if android version is at or above 8.0 and
    // needs notification channeling
    // note: version code for oreo was not available
    private boolean isChannelNeeded() {
        return Build.VERSION.SDK_INT >= 26;
    }
}
