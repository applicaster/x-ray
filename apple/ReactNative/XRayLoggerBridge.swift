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
class XRayLoggerBridge: NSObject, RCTBridgeModule {
    var bridge: RCTBridge!

    static func moduleName() -> String! {
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
            Xray.sharedInstance.hasSinks(loggerSubsystem: subsystem,
                                               category: category,
                                               logLevel: logLevel) else {
            return
        }
        let newSubsystem = "\(Bundle.main.bundleIdentifier!)/quick_brick/\(subsystem)"
        let event = Event(category: category,
                          subsystem: newSubsystem,
                          timestamp: UInt(round(NSDate().timeIntervalSince1970)),
                          level: logLevel,
                          message: message,
                          data: eventData["data"] as? [String: Any],
                          context: eventData["context"] as? [String: Any],
                          exception: nil)
        Xray.sharedInstance.submit(event: event)
    }
}
