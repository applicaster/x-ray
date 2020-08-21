package com.applicaster.xray.core.utility;

import com.applicaster.xray.core.Core;

public class Stack {

    public static int getClientCodeFrameOffset(StackTraceElement[] stackTrace){
        // 0 is system code, 1 is logger library code, 2 is calling code
        String selfPackageName = Core.class.getPackage().getName();
        boolean reachedSelf = false;
        for (int i = 0; i < stackTrace.length; i++) {
            StackTraceElement stackTraceElement = stackTrace[i];
            if (stackTraceElement.getClassName().startsWith(selfPackageName)) {
                reachedSelf = true; // arrived to the our part of the stack
                continue; // still in logger stack
            }
            if (reachedSelf) {
                return i; // finally out of our part of the stack
            }  // else still in low level code
        }
        return 0; // could not find user code, return all frames
    }

}
