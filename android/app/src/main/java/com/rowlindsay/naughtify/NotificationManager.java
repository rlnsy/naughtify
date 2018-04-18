package com.rowlindsay.naughtify;

import android.service.notification.StatusBarNotification;

import java.util.HashSet;
import java.util.Set;

public class NotificationManager {

    // TODO: make this a non-native class

    private Set<ManagedEntryNotification> notifications;

    public NotificationManager() {
        notifications = new HashSet<>();
    }

    public void add(StatusBarNotification sbn) {
        ManagedEntryNotification entry = new ManagedEntryNotification(sbn);
        if (!notifications.contains(entry))
            notifications.add(entry);
    }

    public int getNum() {
        return notifications.size();
    }
}
