//
//  DetailedObjectLoggerViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class DetailedObjectLoggerViewController: UIViewController, MFMailComposeViewControllerDelegate {
    let cellIdentifier = "DetailedDictionaryLoggerViewController"

    @IBOutlet weak var backgroundDataView: UIView!
    @IBOutlet weak var loggerTypeView: UIView!
    @IBOutlet weak var logTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let defaultEventFormatter = DefaultEventFormatter()
    var dateString: String?

    var event: Event?
    var dataObject: Any? {
        didSet {
            dataSource = SectionDataSourceHelper.prepareDataSource(dataObject: dataObject)
        }
    }

    var dataSource: [SectionModel] = []
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

extension DetailedObjectLoggerViewController: UITableViewDataSource {
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
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = dataSource[section]
        return sectionData.value == nil ? 1 : 2
    }
}

extension DetailedObjectLoggerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        let sectionData = dataSource[indexPath.section]

        guard let dataObject = sectionData.dataObject,
            let event = event else {
            return
        }

        let bundle = Bundle(for: type(of: self))
        let detailedViewController = DetailedObjectLoggerViewController(nibName: "DetailedObjectLoggerViewController",
                                                                        bundle: bundle)
        detailedViewController.event = event
        detailedViewController.dateString = dateString
        detailedViewController.dataObject = dataObject
        detailedViewController.title = sectionData.key
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
    }
}

extension DetailedObjectLoggerViewController {
    func updateTypeCell(indexPath: IndexPath,
                        cell: UITableViewCell) {
        let sectionData = dataSource[indexPath.section]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.textLabel?.text = sectionData.key

        if sectionData.dataObject == nil {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
    }

    func updateDetailCell(indexPath: IndexPath,
                          cell: UITableViewCell) {
        let sectionData = dataSource[indexPath.section]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = .none
        cell.textLabel?.text = sectionData.value
        cell.backgroundColor = UIColor.clear
    }
}
