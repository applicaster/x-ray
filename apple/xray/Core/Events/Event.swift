//
//  Event.swift
//  xray
//
//  Created by Anton Kononenko on 7/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

class Event: NSObject {
    let category: String?
    let subsystem: String
    let timestamp: UInt // UTC
    let level: Int
    let message: String
    let data: [String: Any]? // What func, line
    let context: [String: Any]?
    let exception: NSException?

    init(category: String?,
         subsystem: String,
         timestamp: UInt,
         level: Int = 0,
         message: String,
         data: [String: Any]?,
         context: [String: Any]?,
         exception: NSException?) {
        self.category = category
        self.subsystem = subsystem
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.data = data
        self.context = context
        self.exception = exception
        super.init()
    }
}
