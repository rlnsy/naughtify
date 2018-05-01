package com.rowlindsay.naughtify;

import android.service.notification.StatusBarNotification;

import java.util.HashSet;
import java.util.Set;

public class AndroidNotificationManager {

    // TODO: make this a non-native class

    private Set<ManagedNotificationEntry> notifications;

    public AndroidNotificationManager() {
        notifications = new HashSet<>();
    }

    public void add(StatusBarNotification sbn) {
        ManagedNotificationEntry entry = new ManagedNotificationEntry(sbn);
        if (!notifications.contains(entry))
            notifications.add(entry);
    }

    public int getNum() {
        return notifications.size();
    }
}