package com.applicaster.xray.accessibility;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.view.accessibility.AccessibilityEvent;

import com.applicaster.xray.core.Logger;

public class EventService extends AccessibilityService {

    private static final String TAG = "EventService";
    private final Logger logger = Logger.get(TAG);
    private String packageName;

    @Override
    public void onServiceConnected() {
        super.onServiceConnected();
        packageName = getPackageName();
        logger.i(TAG).message("Service started");
        AccessibilityServiceInfo info = getServiceInfo();
        info.flags |= AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS;
        info.flags |= AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS;
        setServiceInfo(info);
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if(!event.getPackageName().equals(packageName)) {
            return;
        }
        // todo: log details to data
        logger.d(TAG).message(event.toString());
    }

    @Override
    public void onInterrupt() {
    }
}
