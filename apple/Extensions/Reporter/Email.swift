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
    var mailComposerCompletion: (() -> Void)?

    deinit {
        print("Deinit")
    }

    func requestSendEmail(emails: [String],
                          sharedFileURL: URL? = nil,
                          contexts: [String: Any]?,
                          attachments: [EmailAttachment]? = nil,
                          completion: (() -> Void)?) {
        if (mailComposeViewController?.presentedViewController) != nil {
            mailComposeViewController?.dismiss(animated: false, completion: { [weak self] in
                guard let self = self else { return }
                self.createMailComposerViewController(emails: emails,
                                                      sharedFileURL: sharedFileURL,
                                                      contexts: contexts,
                                                      attachments: attachments,
                                                      completion: completion)
            })
        } else {
            createMailComposerViewController(emails: emails,
                                             sharedFileURL: sharedFileURL,
                                             contexts: contexts,
                                             attachments: attachments,
                                             completion: completion)
        }
    }

    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    func createMailComposerViewController(emails: [String],
                                          sharedFileURL: URL? = nil,
                                          contexts: [String: Any]?,
                                          attachments: [EmailAttachment]? = nil,
                                          completion: (() -> Void)?) {
        mailComposerCompletion = completion
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
        presentController(vc: mail)
    }

    func createMessageBody(contexts: [String: Any]?) -> String {
        var retVal = defaultEmailBody
        guard let contexts = contexts else {
            return retVal
        }
        // sort by key
        let sortedContexts = contexts.sorted { $0.0 < $1.0 }

        retVal.append("\n")
        for context in sortedContexts {
            retVal.append("\(context.key): \(context.value)\n")
        }
        retVal.append("\n")
        return retVal
    }

    func presentController(vc: UIViewController) {
        if let viewController = UIApplication.topViewController() {
            viewController.present(vc,
                                   animated: true,
                                   completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        mailComposerCompletion?()
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
