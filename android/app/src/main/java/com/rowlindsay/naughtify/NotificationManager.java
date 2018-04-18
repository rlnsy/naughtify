package com.rowlindsay.naughtify;

import android.service.notification.StatusBarNotification;

import java.util.HashSet;
import java.util.Set;

public class NotificationManager {

    // TODO: make this a non-native class

    private Set<StatusBarNotification> notifications;

    public NotificationManager() {
        notifications = new HashSet<>();
    }

    public void add(StatusBarNotification sbn) {
        notifications.add(sbn);
    }

    public int getNum() {
        return notifications.size();
    }
}
