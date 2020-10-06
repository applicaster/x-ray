//
//  DetailedLoggerJSONViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class DetailedLoggerJSONViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var backgroundDataView: UIView!
    @IBOutlet weak var loggerTypeView: UIView!
    @IBOutlet weak var logTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var jsonTextView: UITextView!

    @IBAction func exportData(_ sender: UIBarButtonItem) {
        if let event = event,
            let data = event.toJSONString()?.data(using: .utf8),
            let dateString = dateString {
            let levelString = event.level.toString()
            let attachment = EmailAttachment(data: data, mimeType: "application/json", fileName: "\(levelString)_\(dateString).json")

            Reporter.requestSendCustomEmail(attachments: [attachment])
        } else {
            Reporter.requestSendCustomEmail(attachments: nil)
        }
    }

    let defaultEventFormatter = DefaultEventFormatter()
    var dateString: String?
    var event: Event?

    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func prepareUI() {
        dateLabel.text = dateString
        loggerTypeView.backgroundColor = event?.level.toColor()
        backgroundDataView.roundCorners(radius: 10)
        if let event = event {
            logTypeLabel.text = event.level.toString()
            logTypeLabel.textColor = event.level.toColor()
            if let prettyPrintedJson = event.toJSONString(options: .prettyPrinted) {
                jsonTextView.text = prettyPrintedJson
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Single Log JSON"
        prepareUI()
    }
}
