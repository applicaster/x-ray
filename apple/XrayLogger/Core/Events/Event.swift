//
//  Event.swift
//  xray
//
//  Created by Anton Kononenko on 7/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

@objc public class Event: NSObject {
    public let category: String
    public let subsystem: String
    public let timestamp: UInt // UTC
    public let level: LogLevel
    public let message: String
    public let data: [String: Any]?
    public let context: [String: Any]?
    public let exception: NSException?

    enum CodingKeys: String, CodingKey {
        case category
        case subsystem
        case timestamp
        case level
        case message
        case data
        case context
        case exception
        case statusCode
    }

    init(category: String,
         subsystem: String,
         timestamp: UInt,
         level: LogLevel = .debug,
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

    public func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            CodingKeys.category.rawValue: category,
            CodingKeys.subsystem.rawValue: subsystem,
            CodingKeys.timestamp.rawValue: timestamp,
            CodingKeys.level.rawValue: level.rawValue,
            CodingKeys.message.rawValue: message]

        if let data = data {
            dictionary[CodingKeys.data.rawValue] = data
        }

        if let context = context {
            dictionary[CodingKeys.context.rawValue] = context
        }
        return dictionary
    }

    public var networkRequestStatusCode: String? {
        return data?[CodingKeys.statusCode.rawValue] as? String
    }

    public func toJSONString(options opt: JSONSerialization.WritingOptions = []) -> String? {
        let jsonData = toDictionary()
        return JSONHelper.convertObjectToJSONString(object: jsonData, options: opt)
    }
}
