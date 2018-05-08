package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import static android.content.ContentValues.TAG;

@TargetApi(25)
public class MainActivity extends FlutterActivity {

    private static final String NOTIFICATION_CHANNEL = "com.rowlindsay/notification";

    private NotificationEventReceiver receiver;

    // client state information
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

            StatusBarNotification infoGot = intent.getParcelableExtra("notification info");
            if (infoGot != null) {
                encoder.encode(infoGot);
                // TODO: only store when neccessary
                // TODO: fix
                storeAppIcon(infoGot.getPackageName());
            }

            if (eventName.equals("notification added") && muteMode)
                clearNotifications();
        }
    }

    private void toggleMuteMode() {
        muteMode = !muteMode;
        AudioManager audio = (AudioManager) getSystemService(AUDIO_SERVICE);
        if (muteMode) {
            // mute mode turned on
            audio.setRingerMode(AudioManager.RINGER_MODE_SILENT);
            encoder.startSession();
            // TODO: figure out how this works with vibrate on silent
        } else {
            // mute mode turned off
            audio.setRingerMode(AudioManager.RINGER_MODE_NORMAL);
            // TODO: retain user's original setting
            encoder.endSession();
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


    // ICON STORING

    private void storeAppIcon(String packName) {
        try {
            Drawable icon = getPackageManager().getApplicationIcon(packName);
            Bitmap bitmap = ((BitmapDrawable) icon).getBitmap();
            Log.d("icon-store","converted image, storing...");
            storeIconFile(bitmap,packName);
        }
        catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

    private void storeIconFile(Bitmap image, String packName) {
        File pictureFile = getIconDir(packName);
        if (pictureFile == null) {
            Log.d(TAG,
                    "Error creating media file, check storage permissions: ");
            return;
        }
        try {
            FileOutputStream fos = new FileOutputStream(pictureFile);
            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.close();
            Log.d("icon-store","closed output stream");
        } catch (FileNotFoundException e) {
            Log.d(TAG, "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d(TAG, "Error accessing file: " + e.getMessage());
        }
    }

    private File getIconDir(String packName) {
        // TODO: top level directory currently hard-coded
        String iconDir = getApplicationInfo().dataDir + "/app_flutter/packicons/";

        File iconsDir = new File(iconDir);
        if (! iconsDir.exists()){
            if (! iconsDir.mkdirs()){
                Log.d("storing","could not make directory");
                return null;
            }
        }

        Log.d("icon storing","directory: " + iconDir);
        return new File( iconDir + packName + ".png");
    }
}
