package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.service.notification.StatusBarNotification;

import java.util.Objects;

@TargetApi(25)
public class ManagedNotificationEntry {
    // Wrapper for the StatusBarNotification class
    // TODO: also make this non-native

    private long timeCode;
    private int id;
    private String packageName;

    public ManagedNotificationEntry(StatusBarNotification sbn) {
        this.timeCode = sbn.getPostTime();
        this.packageName = sbn.getPackageName();
        this.id = sbn.getId();
    }

    // temporarily using only packageName and id, TODO: figure out why two always come

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ManagedNotificationEntry that = (ManagedNotificationEntry) o;
        return id == that.id &&
                Objects.equals(packageName, that.packageName);
    }

    @Override
    public int hashCode() {

        return Objects.hash(id, packageName);
    }
}
