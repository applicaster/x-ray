//
//  Email.swift
//  xray
//
//  Created by Anton Kononenko on 7/23/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import MessageUI
import MobileCoreServices

class Email: NSObject, MFMailComposeViewControllerDelegate {
    public var emailSubject = "Application Logs"
    public var defaultEmailBody = ""
    public var emailContextData: [String: AnyObject] = [:]
    public var emailAttachments: [EmailAttachment] = []
    var mailComposeViewController: MFMailComposeViewController?

    deinit {
        print("Deinit")
    }

    func requestSendEmail(emails: [String],
                          sharedFileURL: URL? = nil,
                          contexts: [String: Any]?,
                          attachments: [EmailAttachment]? = nil,
                          presenter: UIViewController? = nil) {
        if (mailComposeViewController?.presentedViewController) != nil {
            mailComposeViewController?.dismiss(animated: false, completion: { [weak self] in
                guard let self = self else { return }
                self.createMailComposerViewController(emails: emails,
                                                      sharedFileURL: sharedFileURL,
                                                      contexts: contexts,
                                                      attachments:attachments,
                                                      presenter: presenter)
            })
        } else {
            createMailComposerViewController(emails: emails,
                                             sharedFileURL: sharedFileURL,
                                             contexts: contexts,
                                             attachments:attachments,
                                             presenter: presenter)
        }
    }

    func createMailComposerViewController(emails: [String],
                                          sharedFileURL: URL? = nil,
                                          contexts: [String: Any]?,
                                          attachments: [EmailAttachment]? = nil,
                                          presenter: UIViewController? = nil) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setSubject(emailSubject)
            mail.setToRecipients(emails)
            mail.setMessageBody(createMessageBody(contexts: contexts),
                                isHTML: false)

            if let sharedFileURL = sharedFileURL,
                let data = dataFromURL(url: sharedFileURL) {
                mail.addAttachmentData(data,
                                       mimeType: mimeTypeFromURL(url: sharedFileURL),
                                       fileName: sharedFileURL.lastPathComponent)
            }

            if let attachments = attachments {
                for attachment in attachments {
                    mail.addAttachmentData(attachment.data,
                                           mimeType: attachment.mimeType,
                                           fileName: attachment.fileName)
                }
            }

            mail.mailComposeDelegate = self
            presentMailCompose(mail: mail)
        } else {
            print("Can not to send email")
        }
    }

    func createMessageBody(contexts: [String: Any]?) -> String {
        var retVal = defaultEmailBody
        guard let contexts = contexts else {
            return retVal
        }
        retVal.append("\n")
        for context in contexts {
            retVal.append("\(context.key):\(context.value)\n")
        }
        retVal.append("\n")
        return retVal
    }

    func presentMailCompose(mail: MFMailComposeViewController) {
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

            if let topController = keyWindow?.rootViewController {
                topController.present(mail, animated: true, completion: nil)
            }
        } else {
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                topController.present(mail, animated: true, completion: nil)
            }
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

//    https://stackoverflow.com/questions/31243371/path-extension-and-mime-type-of-file-in-swift
    func mimeTypeFromURL(url: URL) -> String {
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }

    func dataFromURL(url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)

            return data
        } catch {
            print("Unable to load data: \(error)")
            return nil
        }
    }
}
