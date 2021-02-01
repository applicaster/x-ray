//
//  Reporter.swift
//  xray
//
//  Created by Anton Kononenko on 7/23/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import MessageUI

public protocol StorableSinkDelegate {
    func getLogFileUrl(_ completion: ((URL?) -> Void)?)
    func deleteLogFile()
}

public class Reporter {
    public static let sharedInstance = Reporter()
    public private(set) static var sharedEmails: [String]?
    public private(set) static var sharedLogFileSinkDelegate: StorableSinkDelegate?
    public private(set) static var sharedContexts: [String: Any]?
    var email = Email()

    public static func setDefaultData(emails: [String],
                                      logFileSinkDelegate: StorableSinkDelegate?,
                                      contexts: [String: Any]?) {
        sharedEmails = emails
        sharedLogFileSinkDelegate = logFileSinkDelegate
        sharedContexts = contexts
    }

    public static func requestSendEmail() {
        guard let sharedEmails = sharedEmails else {
            print("Cannot send email, at least one sender must be defined")
            return
        }

        guard sharedInstance.email.canSendMail() else {
            let alert = UIAlertController(title: "Cannot send email", message: "Please check if your device has email configured", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            sharedInstance.email.presentController(vc: alert)
            return
        }

        sharedLogFileSinkDelegate?.getLogFileUrl({ url in
            if let url = url {
                sharedInstance.email.requestSendEmail(emails: sharedEmails,
                                                      sharedFileURL: url,
                                                      contexts: sharedContexts,
                                                      attachments: nil,
                                                      completion: {
                                                          sharedLogFileSinkDelegate?.deleteLogFile()
                                                      })
            }
        })
    }

    public static func requestSendCustomEmail(attachments: [EmailAttachment]? = nil) {
        guard let emails = sharedEmails else {
            print("Cannot send email, at least one sender must be defined")
            return
        }

        sharedInstance.email.requestSendEmail(emails: emails,
                                              sharedFileURL: nil,
                                              contexts: sharedContexts,
                                              attachments: attachments,
                                              completion: {
                                                  sharedLogFileSinkDelegate?.deleteLogFile()
                                              })
    }
}
