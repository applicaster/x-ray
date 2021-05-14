//
//  Logger.swift
//  xray
//
//  Created by Anton Kononenko on 7/10/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class Logger: NSObject {
    static let rootLogger = Logger(subsystem: "",
                                   parent: nil)
    public let subsystem: String
    private(set) var children: [String: Logger] = [:]
    weak var parent: Logger?

    public var context: [String: Any] = [:]
    var messageFormatter: MessageFormatterProtocol?

    init(subsystem: String,
         parent: Logger?) {
        self.subsystem = subsystem
        self.parent = parent
        if parent == nil {
            messageFormatter = DefaultMessageFormatter()
        }
        super.init()
    }

    func createChildLogger(subsystem: String) -> Logger {
        let childLogger = Logger(subsystem: subsystem,
                                 parent: self)
        children[subsystem] = childLogger
        return childLogger
    }

    public func verboseLog(message: String,
                           category: String = "",
                           data: [String: Any]? = nil,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           args: [CVarArg] = []) {
        let newData = populateData(data: data,
                                   file: file,
                                   function: function,
                                   line: line,
                                   includeCallStackSymbols: false)

        EventBuilder.submit(subsystem: subsystem,
                            logLevel: .verbose,
                            category: category,
                            data: newData,
                            context: getFullContext(),
                            messageFormatter: resolveMessageFormatter(),
                            message: message,
                            exception: nil,
                            args: args)
    }

    public func debugLog(message: String,
                         category: String = "",
                         data: [String: Any]? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         args: [CVarArg] = []) {
        let newData = populateData(data: data,
                                   file: file,
                                   function: function,
                                   line: line,
                                   includeCallStackSymbols: false)

        EventBuilder.submit(subsystem: subsystem,
                            logLevel: .debug,
                            category: category,
                            data: newData,
                            context: getFullContext(),
                            messageFormatter: resolveMessageFormatter(),
                            message: message,
                            exception: nil,
                            args: args)
    }

    public func infoLog(message: String,
                        category: String = "",
                        data: [String: Any]? = nil,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line,
                        args: [CVarArg] = []) {
        let newData = populateData(data: data,
                                   file: file,
                                   function: function,
                                   line: line,
                                   includeCallStackSymbols: false)

        EventBuilder.submit(subsystem: subsystem,
                            logLevel: .info,
                            category: category,
                            data: newData,
                            context: getFullContext(),
                            messageFormatter: resolveMessageFormatter(),
                            message: message,
                            exception: nil,
                            args: args)
    }

    public func warningLog(message: String,
                           category: String = "",
                           data: [String: Any]? = nil,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           args: [CVarArg] = []) {
        let newData = populateData(data: data,
                                   file: file,
                                   function: function,
                                   line: line,
                                   includeCallStackSymbols: false)

        EventBuilder.submit(subsystem: subsystem,
                            logLevel: .warning,
                            category: category,
                            data: newData,
                            context: getFullContext(),
                            messageFormatter: resolveMessageFormatter(),
                            message: message,
                            exception: nil,
                            args: args)
    }

    public func errorLog(message: String,
                         category: String = "",
                         data: [String: Any]? = nil,
                         exception: NSException? = nil,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         args: [CVarArg] = []) {
        let newData = populateData(data: data,
                                   file: file,
                                   function: function,
                                   line: line,
                                   includeCallStackSymbols: false)

        EventBuilder.submit(subsystem: subsystem,
                            logLevel: .error,
                            category: category,
                            data: newData,
                            context: getFullContext(),
                            messageFormatter: resolveMessageFormatter(),
                            message: message,
                            exception: exception,
                            args: args)
    }

    func resolveMessageFormatter() -> MessageFormatterProtocol? {
        DispatchQueue.global(qos: .default).sync {
            guard let messageFormatter = messageFormatter else {
                return parent != nil ? parent?.resolveMessageFormatter() : nil
            }

            return messageFormatter
        }
    }

    func getFullContext() -> [String: Any] {
        var retVal: [String: Any] = [:]
        if let parent = parent {
            retVal.merge(parent.getFullContext()) { _, new in new }
        }
        retVal.merge(context) { _, new in new }
        return retVal
    }

    public static func getLogger(for subsystem: String? = nil) -> Logger? {
        guard let subsystem = subsystem,
            subsystem.isEmpty == false else {
            return rootLogger
        }
        return rootLogger.child(for: subsystem)
    }

    func getLogger(for subsystem: String) -> Logger? {
        if self.subsystem == subsystem {
            return self
        }
        return child(for: subsystem)
    }

    func child(for subsystem: String) -> Logger? {
        if let searchedSubsystem = children[subsystem] {
            return searchedSubsystem
        }

        if let nextSubsystemLevel = LoggerUtils.getNextSubsystem(subsystem: subsystem,
                                                                 parentSubsystem: self.subsystem) {
            return childInNextSubsystemLevel(targetSubsystem: subsystem,
                                             nextSubsystemToSearch: nextSubsystemLevel)
        }

        return nil
    }

    func childInNextSubsystemLevel(targetSubsystem: String,
                                   nextSubsystemToSearch: String) -> Logger? {
        if let searchedItem = children[nextSubsystemToSearch] {
            return searchedItem.getLogger(for: targetSubsystem)
        } else {
            let newChild = createChildLogger(subsystem: nextSubsystemToSearch)
            return newChild.getLogger(for: targetSubsystem)
        }
    }

    func populateData(data: [String: Any]?,
                      file: String,
                      function: String,
                      line: Int,
                      includeCallStackSymbols: Bool = false) -> [String: Any]? {
        guard let data = data else {
            return nil
        }

        var newData = data
        newData["location"] = ["file": file,
                               "function": function,
                               "line": line]
        if includeCallStackSymbols == true {
            newData["stack_symbols"] = Thread.callStackSymbols
        }
        let name = __dispatch_queue_get_label(nil)
        let threadName = String(cString: name, encoding: .utf8) ?? Thread.current.description

        newData["thread"] = [
            "priority": Thread.threadPriority(),
            "main_thread": Thread.current.isMainThread,
            "thread_name": threadName,
        ]
        return newData
    }
}
