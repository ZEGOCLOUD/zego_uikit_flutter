package com.zegocloud.uikit.zego_uikit_plugin;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.app.KeyguardManager;
import android.os.PowerManager;
import android.view.WindowManager;
import im.zego.uikit.libuikitreport.*;
import java.util.Map;
import java.util.List;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * ZegoUikitPlugin
 */
public class ZegoUikitPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private static final String TAG = "ZegoUikitPlugin";

    private MethodChannel methodChannel;
    private Context context;
    private ActivityPluginBinding activityBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine");
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zego_uikit_plugin");
        methodChannel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d(TAG, "onMethodCall: " + call.method);
        switch (call.method) {
            case Defines.FLUTTER_API_FUNC_BACK_TO_DESKTOP:
                backToDesktop(call.argument(Defines.FLUTTER_PARAM_NON_ROOT));
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_IS_LOCK_SCREEN:
                result.success(isLockScreen());
                break;
            case Defines.FLUTTER_API_FUNC_CHECK_APP_RUNNING:
                result.success(isAppRunning());
                break;
            case Defines.FLUTTER_API_FUNC_ACTIVE_APP_TO_FOREGROUND:
                activeAppToForeground(context);
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_REQUEST_DISMISS_KEYGUARD:
                requestDismissKeyguard(context, activityBinding.getActivity());
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_REPORTER_CREATE:
                handleReporterCreate(call, result);
                break;
            case Defines.FLUTTER_API_FUNC_REPORTER_DESTROY:
                ReportUtil.destroy();
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_REPORTER_UPDATE_TOKEN:
                ReportUtil.updateToken(call.argument("token"));
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_REPORTER_UPDATE_COMMON_PARAMS:
                ReportUtil.updateCommonParams(call.argument("params"));
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_REPORTER_EVENT:
                handleReporterEvent(call);
                result.success(null);
                break;
            case Defines.FLUTTER_API_FUNC_OPEN_APP_SETTINGS:
                openAppSettings();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleReporterCreate(MethodCall call, Result result) {
        int appID = call.argument("app_id");
        String signOrToken = call.argument("sign_token");
        Map<String, Object> commonParams = call.argument("params");
        ReportUtil.create(appID, signOrToken, commonParams);
        result.success(null);
    }

    private void handleReporterEvent(MethodCall call) {
        String event = call.argument("event");
        Map<String, Object> paramsMap = call.argument("params");
        ReportUtil.reportEvent(event, paramsMap);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity");
        this.activityBinding = activityPluginBinding;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges");
        this.activityBinding = activityPluginBinding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges");
        this.activityBinding = null;
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity");
        this.activityBinding = null;
    }

    public void backToDesktop(Boolean nonRoot) {
        Log.i(TAG, "backToDesktop nonRoot:" + nonRoot);
        try {
            activityBinding.getActivity().moveTaskToBack(nonRoot);
        } catch (Exception e) {
            Log.e(TAG, "Error in backToDesktop", e);
        }
    }

    public Boolean isLockScreen() {
        Log.i(TAG, "isLockScreen");
        KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        boolean isLocked = keyguardManager.inKeyguardRestrictedInputMode();

        if (!isLocked) {
            PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            isLocked = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH ? !powerManager.isInteractive() : !powerManager.isScreenOn();
        }

        return isLocked;
    }

    private boolean isAppRunning() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningAppProcessInfo> runningAppProcesses = activityManager.getRunningAppProcesses();
            if (runningAppProcesses != null) {
                for (ActivityManager.RunningAppProcessInfo processInfo : runningAppProcesses) {
                    Log.d(TAG, "running app: " + processInfo.processName);
                    if (processInfo.processName.equals(context.getPackageName())) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public void activeAppToForeground(Context context) {
        Log.d(TAG, "active app to foreground");
        String packageName = context.getPackageName();
        Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);

        if (intent != null) {
            if (Build.VERSION.SDK_INT < 29) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
                    for (ActivityManager.AppTask appTask : am.getAppTasks()) {
                        if (appTask.getTaskInfo().baseActivity.getPackageName().equals(packageName)) {
                            appTask.moveToFront();
                            return;
                        }
                    }
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            } else {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            }
            context.startActivity(intent);
        } else {
            Log.d(TAG, "Launch intent is null");
        }
    }

    public void requestDismissKeyguard(Context context, Activity activity) {
        Log.d(TAG, "request dismiss keyguard");
        if (activity == null) {
            Log.d(TAG, "activity is null");
            return;
        }

        KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1 && keyguardManager.isKeyguardLocked()) {
            keyguardManager.requestDismissKeyguard(activity, null);
        } else {
            WindowManager.LayoutParams params = activity.getWindow().getAttributes();
            params.flags |= WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD;
            activity.getWindow().setAttributes(params);
        }
    }

    private void openAppSettings() {
        Log.d(TAG, "openAppSettings");
        try {
            Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            android.net.Uri uri = android.net.Uri.fromParts("package", context.getPackageName(), null);
            intent.setData(uri);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            Log.e(TAG, "Error in openAppSettings", e);
        }
    }
}