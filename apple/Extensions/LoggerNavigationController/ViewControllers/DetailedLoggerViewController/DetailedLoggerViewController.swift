//
//  DetailedLoggerViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
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

class DetailedLoggerViewController: UIViewController, MFMailComposeViewControllerDelegate {
    let cellIdentifier = "DetailedLoggerViewController"
    let numberOfSections = 5 // Currently no Exception supported
    let numberOfRowsInSection = 2

    @IBOutlet weak var backgroundDataView: UIView!
    @IBOutlet weak var loggerTypeView: UIView!
    @IBOutlet weak var logTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

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

    @IBAction func readJSON(_ sender: UIBarButtonItem) {
        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedLoggerJSONViewController(nibName: "DetailedLoggerJSONViewController",
                                                                      bundle: bundle)
        detailedViewController.event = event
        detailedViewController.dateString = dateString
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        prepareUI()
        title = "Single Log"
    }

    func prepareUI() {
        dateLabel.text = dateString
        loggerTypeView.backgroundColor = event?.level.toColor()
        backgroundDataView.roundCorners(radius: 10)
        if let event = event {
            logTypeLabel.text = event.level.toString()
            logTypeLabel.textColor = event.level.toColor()
        }
    }
}

extension DetailedLoggerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)

        if indexPath.row == 0 {
            updateTypeCell(indexPath: indexPath,
                           cell: cell)
        } else {
            updateDetailCell(indexPath: indexPath,
                             cell: cell)
        }
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
}

extension DetailedLoggerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        guard let event = event,
            let currentSection = DetailedLoggerSections(rawValue: indexPath.section) else {
            return
        }

        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedObjectLoggerViewController(nibName: "DetailedObjectLoggerViewController",
                                                                        bundle: bundle)
        detailedViewController.event = event
        detailedViewController.dateString = dateString

        switch currentSection {
        case DetailedLoggerSections.data:
            if let data = event.data,
                data.count > 0 {
                detailedViewController.dataObject = data
                detailedViewController.title = DetailedLoggerSections.data.toString()
                navigationController?.pushViewController(detailedViewController,
                                                         animated: true)
            }
        case DetailedLoggerSections.context:
            if let context = event.context,
                context.count > 0 {
                detailedViewController.dataObject = context
                detailedViewController.title = DetailedLoggerSections.context.toString()
                navigationController?.pushViewController(detailedViewController,
                                                         animated: true)
            }
        case DetailedLoggerSections.exception:
            if let exception = event.exception {
                detailedViewController.title = DetailedLoggerSections.exception.toString()
                navigationController?.pushViewController(detailedViewController,
                                                         animated: true)
            }
        default:
            break
        }
    }
}

extension DetailedLoggerViewController {
    func updateTypeCell(indexPath: IndexPath,
                        cell: UITableViewCell) {
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.textLabel?.text = DetailedLoggerSections(rawValue: indexPath.section)?.toString()
        let isDiscosureIndicatorDisabled = indexPath.section == DetailedLoggerSections.category.rawValue ||
            indexPath.section == DetailedLoggerSections.subsystem.rawValue ||
            indexPath.section == DetailedLoggerSections.message.rawValue
        cell.accessoryType = isDiscosureIndicatorDisabled ? .none : .disclosureIndicator

        guard let event = event,
            let currentSection = DetailedLoggerSections(rawValue: indexPath.section) else {
            return
        }

        switch currentSection {
        case DetailedLoggerSections.data:
            if let dataCount = event.data?.count,
                dataCount == 0 {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.darkGray
            }
        case DetailedLoggerSections.context:
            if let contextCount = event.context?.count,
                contextCount == 0 {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.darkGray
            }
        case DetailedLoggerSections.exception:
            if event.exception == nil {
                cell.accessoryType = .none
                cell.textLabel?.textColor = UIColor.darkGray
            }
        default:
            break
        }
    }

    func updateDetailCell(indexPath: IndexPath,
                          cell: UITableViewCell) {
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = .none
        cell.backgroundColor = UIColor.clear

        let noDataText = "No data availible"
        guard let event = event,
            let currentSection = DetailedLoggerSections(rawValue: indexPath.section) else {
            cell.textLabel?.text = noDataText
            return
        }

        switch currentSection {
        case DetailedLoggerSections.category:
            if event.category.isEmpty == false {
                cell.textLabel?.text = event.category
            } else {
                cell.textLabel?.text = noDataText
                cell.textLabel?.textColor = UIColor.darkGray
            }
        case DetailedLoggerSections.subsystem:
            cell.textLabel?.text = event.subsystem
        case DetailedLoggerSections.message:
            cell.textLabel?.text = event.message
        case DetailedLoggerSections.data:
            if let data = event.data {
                cell.textLabel?.text = "Items: \(data.count)"
            } else {
                cell.textLabel?.text = noDataText
                cell.textLabel?.textColor = UIColor.darkGray
            }
        case DetailedLoggerSections.context:
            if let context = event.context {
                cell.textLabel?.text = "Items: \(context.count)"
            } else {
                cell.textLabel?.text = noDataText
                cell.textLabel?.textColor = UIColor.darkGray
            }
        case DetailedLoggerSections.exception:
            if let exception = event.exception {
                if let reason = exception.reason {
                    cell.textLabel?.text = "Reason: \(reason)"

                } else {
                    cell.textLabel?.text = "Name: \(exception.name)"
                }
            } else {
                cell.textLabel?.text = noDataText
                cell.textLabel?.textColor = UIColor.darkGray
            }
        }
    }
}
