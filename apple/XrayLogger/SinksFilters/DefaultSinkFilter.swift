//
//  DefaultSinkFilter.swift
//  xray
//
//  Created by Anton Kononenko on 7/15/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class DefaultSinkFilter: NSObject, SinkFilterProtocol {
    public private(set) var minLevel: LogLevel = .debug

    public init(level: LogLevel) {
        super.init()
        minLevel = level
    }

    public func accept(loggerSubsystem: String,
                       category: String,
                       logLevel: LogLevel) -> Bool {
        return minLevel.rawValue <= logLevel.rawValue
    }
}
