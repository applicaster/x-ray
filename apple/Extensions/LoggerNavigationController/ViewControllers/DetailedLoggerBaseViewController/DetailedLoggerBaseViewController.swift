//
//  DetailedLoggerBaseViewController.swift
//  LoggerInfo
//
//  Created by Alex Zchut on 01/03/2021.
//

import Reporter
import UIKit
import XrayLogger

enum DetailedLoggerSections: Int {
    case message
    case category
    case subsystem
    case data
    case context
    case exception

    func toString() -> String {
        switch self {
        case DetailedLoggerSections.message:
            return "Message"
        case DetailedLoggerSections.category:
            return "Category"
        case DetailedLoggerSections.subsystem:
            return "Subsystem"
        case DetailedLoggerSections.data:
            return "Data"
        case DetailedLoggerSections.context:
            return "Context"
        case DetailedLoggerSections.exception:
            return "Exception"
        }
    }
}

class DetailedLoggerBaseViewController: UIViewController {

    @IBOutlet weak var backgroundDataView: UIView!
    @IBOutlet weak var loggerTypeView: UIView!
    @IBOutlet weak var logTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let defaultEventFormatter = DefaultEventFormatter()
    var dateString: String?
    var event: Event?
    var loggerType: LoggerViewType = .undefined
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil,
                   bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func exportData(_ sender: UIBarButtonItem) {
        if let event = event,
            let data = event.toJSONString()?.data(using: .utf8),
            let dateString = dateString {
            let levelString = event.level.toString()
            let attachment = EmailAttachment(data: data,
                                             mimeType: "application/json",
                                             fileName: "\(levelString)_\(dateString).json")

            Reporter.requestSendCustomEmail(attachments: [attachment])
        } else {
            Reporter.requestSendCustomEmail(attachments: nil)
        }
    }
    
    func prepareUI() {
        dateLabel.text = dateString
        backgroundDataView.roundCorners(radius: 10)
        if let event = event {
            switch loggerType {
            case .logger:
                logTypeLabel.text = event.level.toString()
                logTypeLabel.textColor = event.level.toColor()
                loggerTypeView.backgroundColor = event.level.toColor()
            case .networkRequests:
                if let statusCodeString = event.networkRequestStatusCode,
                   let networkRequestStatusCode = NetworkRequestStatusCode(statusCode: statusCodeString),
                   let httpStatusCode = HTTPStatusCode(rawValue: Int(networkRequestStatusCode.rawValue)) {
                    logTypeLabel.text = httpStatusCode.description
                    logTypeLabel.textColor = networkRequestStatusCode.toColor()
                    loggerTypeView.backgroundColor = networkRequestStatusCode.toColor()
                    dateLabel.text = ""
                }

            default:
                break
            }
        }
    }
}

