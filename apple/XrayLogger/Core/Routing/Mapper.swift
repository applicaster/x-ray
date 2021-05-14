//
//  Mapper.swift
//  xray
//
//  Created by Anton Kononenko on 7/10/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

class Mapper {
    private(set) var sinksIdentifiers: Set<String> = []
    private var loggerMapping: [String: [String: SinkFilterProtocol]] = [:]
    func refreshSinks(sinks: [String: SinkProtocol]) {
        sinksIdentifiers = Set(sinks.keys)
    }

    func setFilter(loggerSubsystem: String,
                   sinkIdentifier: String,
                   filter: SinkFilterProtocol?) {
        DispatchQueue.global(qos: .default).sync { [weak self] in
            guard let self = self else { return }
            var newMappedSubsystem: [String: SinkFilterProtocol]?

            if let mappedSubsystem = self.loggerMapping[loggerSubsystem] {
                newMappedSubsystem = mappedSubsystem
                newMappedSubsystem?[sinkIdentifier] = filter
                if mappedSubsystem.keys.count == 0 {
                    newMappedSubsystem = nil
                }
            } else if let filter = filter {
                newMappedSubsystem = [sinkIdentifier: filter]
            }

            self.loggerMapping[loggerSubsystem] = newMappedSubsystem
        }
    }

    private func getClosestMapping(loggerSubsystem: String) -> [String: SinkFilterProtocol]? {
        DispatchQueue.global(qos: .default).sync {
            if loggerSubsystem == "" {
                return loggerMapping[""]
            }

            if let mappedSinks = loggerMapping[loggerSubsystem] {
                return mappedSinks
            }

            var parentSubsystem = loggerSubsystem.retrieveParentSubsystemPath()
            while parentSubsystem != nil {
                if let parentSubsystem = parentSubsystem,
                    let parentMappedSinks = loggerMapping[parentSubsystem] {
                    return parentMappedSinks
                }

                parentSubsystem = parentSubsystem?.retrieveParentSubsystemPath()
            }

            return loggerMapping[""]
        }
    }

    public func getMapping(loggerSubsystem: String,
                           category: String,
                           logLevel: LogLevel) -> Set<String>? {
        var retVal: Set<String>

        retVal = Set(sinksIdentifiers)

        guard let mappedSinks = getClosestMapping(loggerSubsystem: loggerSubsystem) else {
            return retVal
        }

        for currentMappedSink in mappedSinks {
            if currentMappedSink.value.accept(loggerSubsystem: loggerSubsystem,
                                              category: category,
                                              logLevel: logLevel) == false {
                retVal.remove(currentMappedSink.key)
            }
        }

        return retVal
    }

    public func hasSinks(loggerSubsystem: String,
                         category: String,
                         logLevel: LogLevel) -> Bool {
        return getMapping(loggerSubsystem: loggerSubsystem,
                          category: category,
                          logLevel: logLevel) != nil
    }
}
