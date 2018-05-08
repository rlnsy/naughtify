package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.content.Intent;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Calendar;

@TargetApi(22)
public class AndroidNotificationEncoder {

    // TODO: handle destruction by ending session and writing to disk

    private JSONArray notificationHistory;

    private JSONObject currentMuteSession;
    private JSONArray sessionNotifications;

    public AndroidNotificationEncoder() {
        notificationHistory = new JSONArray();
    }

    // no-op if not in a session
    public void encode(Intent infoIntent) {
        if (inSession()) {
            JSONObject info = new JSONObject();
            try {
                info.put("timecode", infoIntent.getLongExtra("timecode",0));
                info.put("packagename", infoIntent.getStringExtra("packagename"));
                info.put("rawinfo",infoIntent.getStringExtra("rawinfo"));
                info.put("title",infoIntent.getStringExtra("title"));
                info.put("text",infoIntent.getStringExtra("text"));
            } catch (JSONException jse) {
                Log.d("android encode", "error enncoding to json");
            }
            sessionNotifications.put(info);
        }
    }

    // returns a string that is encoded json - all notifications
    // received in this lifetime
    public String getHistory() {
        return notificationHistory.toString();
    }

    public void startSession() {
        if (!inSession()) {
            currentMuteSession = new JSONObject();
            try {
                currentMuteSession.put("starttime", getTime());
            } catch (JSONException jse) {
                Log.d("android encode", "error encoding start time");
            }
            sessionNotifications = new JSONArray();
        }
    }

    public void endSession() {
        if (inSession()) {
            try {
                currentMuteSession.put("endtime",getTime());
                currentMuteSession.put("notifications", sessionNotifications);
            } catch (JSONException jse) {
                Log.d("android encode", "error enncoding to json");
            }
            notificationHistory.put(currentMuteSession);
            currentMuteSession = null;
            sessionNotifications = null;
        }
    }

    private String getTime() {
        return Calendar.getInstance().getTime().toString();
    }

    public boolean inSession() {
        return currentMuteSession != null;
    }

}
