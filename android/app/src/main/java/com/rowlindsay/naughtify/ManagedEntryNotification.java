package com.rowlindsay.naughtify;

import android.annotation.TargetApi;
import android.service.notification.StatusBarNotification;

import java.util.Objects;

@TargetApi(25)
public class ManagedEntryNotification {
    // Wrapper for the StatusBarNotification class
    // TODO: also make this non-native

    private long timeCode;
    private String packageName;

    public ManagedEntryNotification(StatusBarNotification sbn) {
        this.timeCode = sbn.getPostTime();
        this.packageName = sbn.getPackageName();
    }

    // temporarily using only packageName, TODO: figure out why two always come

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ManagedEntryNotification that = (ManagedEntryNotification) o;
        return Objects.equals(packageName, that.packageName);
    }

    @Override
    public int hashCode() {

        return Objects.hash(packageName);
    }
}
