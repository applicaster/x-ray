//
//  XRayLoggerBridge.swift
//  xray
//
//  Created by Anton Kononenko on 7/17/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import React

@objc(XRayLoggerBridge)
public class XRayLoggerBridge: NSObject, RCTBridgeModule {
    public static var customLogLevel: LogLevel?

    public var bridge: RCTBridge!

    public static func moduleName() -> String! {
        return "XRayLoggerBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    @objc func logEvent(_ eventData: [String: Any]?) {
        let category = eventData?["category"] as? String ?? ""
        guard let eventData = eventData,
            let subsystem = eventData["subsystem"] as? String,
            let level = eventData["level"] as? NSInteger,
            let message = eventData["message"] as? String,
            let logLevel = LogLevel(rawValue: level),
            XrayLogger.sharedInstance.hasSinks(loggerSubsystem: subsystem,
                                               category: category,
                                               logLevel: logLevel) else {
            return
        }

        if shouldSendRNLogs(logLevel: logLevel) {
            let newSubsystem = "\(Bundle.main.bundleIdentifier!)/quick_brick/\(subsystem)"
            let event = Event(category: category,
                              subsystem: newSubsystem,
                              timestamp: UInt(round(NSDate().timeIntervalSince1970)),
                              level: logLevel,
                              message: message,
                              data: eventData["data"] as? [String: Any],
                              context: eventData["context"] as? [String: Any],
                              exception: nil)
            XrayLogger.sharedInstance.submit(event: event)
        }
    }

    func shouldSendRNLogs(logLevel: LogLevel) -> Bool {
        if let customLogLevel = XRayLoggerBridge.customLogLevel,
            logLevel.rawValue < customLogLevel.rawValue {
            return false
        }
        return true
    }
}
