package com.weorbis.motion_detector;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.google.android.gms.location.ActivityRecognition;
import com.google.android.gms.tasks.Task;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

/**
 * The main plugin class for the weorbis_motion_detector package.
 * This class handles the communication between Flutter and the native Android APIs.
 */
@SuppressLint("LongLogTag")
public class MotionDetectorPlugin implements FlutterPlugin, EventChannel.StreamHandler, ActivityAware,
        SharedPreferences.OnSharedPreferenceChangeListener {
    private EventChannel channel;
    private EventChannel.EventSink eventSink;
    private Context androidContext;
    public static final String DETECTED_ACTIVITY = "detected_activity";
    public static final String MOTION_DETECTOR = "com.weorbis.motion_detector.preferences";
    private final String TAG = "weorbis_motion_detector";
    public static final String EVENT_CHANNEL = "weorbis_motion_detector";
    public static final String PREFS_NAME   = "com.weorbis.motion_detector.preferences";

    private String notificationTitle;
    private String notificationText;
    private String notificationIcon;
    private int notificationId;
    private int notificationImportance;
    private long androidUpdateIntervalMillis;

    /**
     * Registers the ActivityRecognitionClient to start receiving activity updates.
     */
    private void startActivityTracking() {
        Intent intent = new Intent(androidContext, ActivityRecognizedBroadcastReceiver.class);
        
        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= 31) {
            flags |= PendingIntent.FLAG_IMMUTABLE;
        }
        PendingIntent pendingIntent = PendingIntent.getBroadcast(androidContext, 0, intent, flags);
        
        Task<Void> task = ActivityRecognition.getClient(androidContext)
                .requestActivityUpdates(this.androidUpdateIntervalMillis, pendingIntent);

        task.addOnSuccessListener(e -> Log.d(TAG, "Successfully registered ActivityRecognition listener."));
        task.addOnFailureListener(e -> Log.d(TAG, "Failed to register ActivityRecognition listener: " + e.getMessage()));
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
        channel.setStreamHandler(this);
        androidContext = flutterPluginBinding.getApplicationContext();
    }

    /**
     * Handles the start of a new stream subscription from Flutter.
     * Parses arguments and starts the foreground service and/or activity tracking.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
        if (arguments instanceof HashMap) {
            @SuppressWarnings("unchecked")
            HashMap<String, Object> args = (HashMap<String, Object>) arguments;
            boolean runForeground = (boolean) args.get("foreground");

            this.notificationTitle = (String) args.get("notificationTitle");
            this.notificationText = (String) args.get("notificationText");
            this.notificationIcon = (String) args.get("notificationIcon");
            this.notificationId = (int) args.get("notificationId");
            this.notificationImportance = (int) args.get("notificationImportance");

            if (args.get("androidUpdateIntervalMillis") != null) {
                this.androidUpdateIntervalMillis = ((Number) args.get("androidUpdateIntervalMillis")).longValue();
            }

            if (runForeground) {
                startForegroundService();
            }
        }
        startActivityTracking();
    }

    /**
     * Starts the foreground service with the configuration provided from Flutter.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    void startForegroundService() {
        Intent intent = new Intent(androidContext, ForegroundService.class);
        intent.putExtra("title", this.notificationTitle)
              .putExtra("text", this.notificationText)
              .putExtra("icon", this.notificationIcon)
              .putExtra("id", this.notificationId)
              .putExtra("importance", this.notificationImportance);
        androidContext.startForegroundService(intent);
    }
    
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setStreamHandler(null);
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        SharedPreferences prefs = androidContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        prefs.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() { }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) { }

    @Override
    public void onDetachedFromActivity() { }

    /**
     * Listens for changes in SharedPreferences, which are written by the
     * ActivityRecognizedService, and forwards the data to Flutter.
     */
    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        if (eventSink != null && key != null && key.equals(DETECTED_ACTIVITY)) {
            String result = sharedPreferences.getString(DETECTED_ACTIVITY, "error");
            eventSink.success(result);
        }
    }
}