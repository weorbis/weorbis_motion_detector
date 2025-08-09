package com.weorbis.motion_detector;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;

import java.util.List;

public class ActivityRecognizedBroadcastReceiver extends BroadcastReceiver {

    private static final String TAG = "ActivityReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) {
            Log.w(TAG, "Received null intent");
            return;
        }

        ActivityRecognitionResult result = ActivityRecognitionResult.extractResult(intent);
        if (result == null) {
            Log.w(TAG, "ActivityRecognitionResult is null from intent");
            return;
        }

        List<DetectedActivity> activities = result.getProbableActivities();
        if (activities == null || activities.isEmpty()) {
            Log.w(TAG, "No detected activities available");
            return;
        }

        // Pick the most confident activity
        DetectedActivity mostLikely = activities.get(0);
        for (DetectedActivity a : activities) {
            if (a.getConfidence() > mostLikely.getConfidence()) {
                mostLikely = a;
            }
        }

        String type = getActivityString(mostLikely.getType());
        int confidence = mostLikely.getConfidence();
        String data = type + "," + confidence;

        Log.d(TAG, "Detected: " + data);

        // Same SharedPreferences name/keys as MotionDetectorPlugin
        SharedPreferences preferences =
                context.getSharedPreferences(MotionDetectorPlugin.PREFS_NAME, Context.MODE_PRIVATE);

        preferences.edit()
                .putString(MotionDetectorPlugin.DETECTED_ACTIVITY, data)
                .apply();
    }

    private static String getActivityString(int type) {
        if (type == DetectedActivity.IN_VEHICLE) return "IN_VEHICLE";
        if (type == DetectedActivity.ON_BICYCLE) return "ON_BICYCLE";
        if (type == DetectedActivity.ON_FOOT) return "ON_FOOT";
        if (type == DetectedActivity.RUNNING) return "RUNNING";
        if (type == DetectedActivity.STILL) return "STILL";
        if (type == DetectedActivity.TILTING) return "TILTING";
        if (type == DetectedActivity.WALKING) return "WALKING";
        return "UNKNOWN";
    }
}
