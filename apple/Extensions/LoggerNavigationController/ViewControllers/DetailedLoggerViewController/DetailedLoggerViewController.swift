//
//  DetailedLoggerViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Reporter
import UIKit
import XrayLogger

class DetailedLoggerViewController: DetailedLoggerBaseViewController {
    var cellIdentifier = "DetailedLoggerViewController"
    let numberOfSections = 5 // Currently no Exception supported
    let numberOfRowsInSection = 2

    @IBAction func readJSON(_ sender: UIBarButtonItem) {
        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedLoggerJSONViewController(nibName: "DetailedLoggerJSONViewController",
                                                                      bundle: bundle)
        detailedViewController.event = event
        detailedViewController.loggerType = loggerType
        detailedViewController.dateString = dateString
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        prepareUI()
        title = "Single Log"
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
        detailedViewController.loggerType = loggerType
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
            if let _ = event.exception {
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
    @objc func updateTypeCell(indexPath: IndexPath,
                              cell: UITableViewCell) {
        cell.backgroundColor = UIColor.clear
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

    @objc func updateDetailCell(indexPath: IndexPath,
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
