//
//  EventBuilder.swift
//  xray
//
//  Created by Anton Kononenko on 7/10/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class EventBuilder: NSObject {
    class func submit(subsystem: String,
                      logLevel: LogLevel = .debug,
                      category: String,
                      data: [String: Any]? = nil,
                      context: [String: Any]? = nil,
                      messageFormatter: MessageFormatterProtocol? = nil,
                      message: String,
                      exception: NSException?,
                      args: [CVarArg] = []) {
        let newMessage = formatMessage(messageFormatter: messageFormatter,
                                       message: message,
                                       data: data,
                                       args: args)
        let newData = argsToData(data: data,
                                 args: args)
        let event = Event(category: category,
                          subsystem: subsystem,
                          timestamp: UInt(round(NSDate().timeIntervalSince1970)),
                          level: logLevel,
                          message: newMessage,
                          data: newData,
                          context: context,
                          exception: exception)
        Xray.sharedInstance.submit(event: event)
    }

    private class func formatMessage(messageFormatter: MessageFormatterProtocol?,
                                     message: String,
                                     data: [String: Any]?,
                                     args: [CVarArg] = []) -> String {
        guard let messageFormatter = messageFormatter else {
            return message
        }
        return messageFormatter.format(template: message,
                                       prameters: data,
                                       args: args)
    }

    private class func argsToData(data: [String: Any]?,
                                  args: [CVarArg]) -> [String: Any]? {
        guard var data = data else {
            return nil
        }

        guard args.count > 0 else {
            return data
        }

        data["message_args"] = args

        return data
    }
}
