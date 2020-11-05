//
//  BaseSink.swift
//  xray
//
//  Created by Anton Kononenko on 7/14/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class BaseSink: NSObject, SinkProtocol {
    
    public var queue: DispatchQueue = {
        let uuid = NSUUID().uuidString
        let queueLabel = "sink-\(uuid)"
        return DispatchQueue(label: queueLabel)
    }()

    open var asynchronously = true
    
    public var formatter: EventFormatterProtocol? = DefaultEventFormatter()

    public func log(event: Event) {
        // Shoulds be implemented on top lovel
    }
    
    public static func == (lhs: BaseSink, rhs: BaseSink) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
