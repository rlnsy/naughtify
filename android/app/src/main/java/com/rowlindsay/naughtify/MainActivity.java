package com.rowlindsay.naughtify;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private NotificationEventReceiver receiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

      receiver = new NotificationEventReceiver();
      IntentFilter filter = new IntentFilter();
      filter.addAction("com.rowlindsay.NOTIFICATION_LISTEN");
      registerReceiver(receiver,filter);
    }

    class NotificationEventReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            String eventName = intent.getStringExtra("notification event");
            Log.d("notification", "event recieve: " + eventName);
        }

    }

}
