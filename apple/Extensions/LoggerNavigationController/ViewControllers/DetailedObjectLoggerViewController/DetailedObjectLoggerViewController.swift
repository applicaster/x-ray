//
//  DetailedObjectLoggerViewController.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Reporter
import UIKit
import XrayLogger

class DetailedObjectLoggerViewController: DetailedLoggerViewController {
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
        cellIdentifier = "DetailedDictionaryLoggerViewController"
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
    }
}

extension DetailedObjectLoggerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = dataSource[section]
        return sectionData.value == nil ? 1 : 2
    }
}

extension DetailedObjectLoggerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        detailedViewController.loggerType = loggerType

        detailedViewController.dateString = dateString
        detailedViewController.dataObject = dataObject
        detailedViewController.title = sectionData.key
        navigationController?.pushViewController(detailedViewController,
                                                 animated: true)
    }
}

extension DetailedObjectLoggerViewController {
    override func updateTypeCell(indexPath: IndexPath,
                                 cell: UITableViewCell) {
        let sectionData = dataSource[indexPath.section]
        cell.backgroundColor = UIColor.clear
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

    override func updateDetailCell(indexPath: IndexPath,
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
