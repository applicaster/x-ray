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
    func getDefaultContexts() -> [String: String]?
}

public class Reporter {
    public static let sharedInstance = Reporter()
    public private(set) static var sharedEmails: [String]?
    public private(set) static var sharedLogFileSinkDelegate: StorableSinkDelegate?
    var email = Email()

    public static func setDefaultData(emails: [String],
                                      logFileSinkDelegate: StorableSinkDelegate?) {
        sharedEmails = emails
        sharedLogFileSinkDelegate = logFileSinkDelegate
    }

    public static func requestSendEmail() {
        guard let sharedEmails = sharedEmails else {
            print("Cannot send email, at least one sender must be defined")
            return
        }

        guard sharedInstance.email.canSendMail() else {
            presentAlertUnableToSendMail()
            return
        }
        
        sharedLogFileSinkDelegate?.getLogFileUrl({ url in
            if let url = url {
                sharedInstance.email.requestSendEmail(emails: sharedEmails,
                                                      sharedFileURL: url,
                                                      contexts: contexts,
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
        
        guard sharedInstance.email.canSendMail() else {
            presentAlertUnableToSendMail()
            return
        }

        sharedInstance.email.requestSendEmail(emails: emails,
                                              sharedFileURL: nil,
                                              contexts: contexts,
                                              attachments: attachments,
                                              completion: {
                                                  sharedLogFileSinkDelegate?.deleteLogFile()
                                              })
    }
    
    static func presentAlertUnableToSendMail() {
        let alert = UIAlertController(title: "Cannot send email", message: "Please check if your device has email configured", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sharedInstance.email.presentController(vc: alert)
    }
    
    static var contexts:[String: Any]? {
        return sharedLogFileSinkDelegate?.getDefaultContexts()
    }
}
