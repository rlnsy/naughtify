package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@TargetApi(25)
public class AndroidNotificationEncoder {

    private JSONArray notificationHistory;

    public AndroidNotificationEncoder() {
        notificationHistory = new JSONArray();
    }

    public void encode(StatusBarNotification sbn) {
        JSONObject info = new JSONObject();
        try {
            info.put("timecode", sbn.getPostTime());
            info.put("packagename", sbn.getPackageName());
        } catch (JSONException jse) {
            Log.d("android encode", "error enncoding to json");
        }
        notificationHistory.put(info);
    }

    // returns a string that is encoded json - all notifications
    // received in this lifetime
    public String getHistory() {
        return notificationHistory.toString();
    }

}
