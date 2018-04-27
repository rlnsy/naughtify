package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.service.notification.StatusBarNotification;

import java.util.Objects;

@TargetApi(25)
public class ManagedNotificationEntry {
    // Wrapper for the StatusBarNotification class
    // TODO: also make this non-native

    private long timeCode;
    private String packageName;

    public ManagedNotificationEntry(StatusBarNotification sbn) {
        this.timeCode = sbn.getPostTime();
        this.packageName = sbn.getPackageName();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ManagedNotificationEntry that = (ManagedNotificationEntry) o;
        return Objects.equals(packageName, that.packageName)
                && (Math.abs(this.timeCode - that.timeCode) < 100);
    }

    @Override
    public int hashCode() {

        return Objects.hash(packageName);
    }
}
