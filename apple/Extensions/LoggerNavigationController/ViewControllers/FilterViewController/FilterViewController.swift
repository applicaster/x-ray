//
//  FilterViewController.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

enum FilterTypes: Int {
    case any
    case subsystem
    case category
    case message

    func toString() -> String {
        switch self {
        case .any:
            return "Any"
        case .subsystem:
            return "Subsystem"
        case .category:
            return "Category"
        case .message:
            return "Message"
        }
    }

    static func allFilterCount() -> Int {
        return 4
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func userDidSaveNewFilterData(filterModels: [DataSortFilterModel])
}

class FilterViewController: UIViewController {
    var data: [String] = []
    let cellIdentifier = "FilterDataCell"

    var filterModels: [DataSortFilterModel] = [] {
        didSet {
            if filterModels.count == 0 {
                createNewFilterModels()
            }
        }
    }

    weak var delegate: FilterViewControllerDelegate?

    @IBOutlet var saveFilterDataButton: FilterButton!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var toggleEditModeButton: UIBarButtonItem!
    @IBOutlet var addNewFilterItemButton: UIBarButtonItem!

    deinit {
        delegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        saveFilterDataButton.backgroundColor = LogLevel.debug.toColor()

        let bundle = Bundle(for: type(of: self))
        tableView.register(UINib(nibName: cellIdentifier,
                                 bundle: bundle),
                           forCellReuseIdentifier: cellIdentifier)
        tableView.roundCorners(radius: 10)
    }

    @IBAction func saveFilterData(_ sender: UIButton) {
        tableView.endEditing(true)
        delegate?.userDidSaveNewFilterData(filterModels: filterModels)
        navigationController?.popViewController(animated: true)
    }

    func createNewFilterModels() {
        var newFilterModels: [DataSortFilterModel] = []
        for index in 0 ..< FilterTypes.allFilterCount() {
            if let type = FilterTypes(rawValue: index) {
                let newModel = DataSortFilterModel(type: type,
                                                   filterText: nil,
                                                   isEnabled: false)
                newFilterModels.append(newModel)
            }
        }
        filterModels = newFilterModels
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)

        if let cell = cell as? FilterDataCell {
            let filterData = filterModels[indexPath.row]
            cell.delegate = self
            cell.updateCellData(filterData: filterData)
        }

        return cell
    }
}

extension FilterViewController: FilterDataCellDelegate {
    func cellDidUpdated(filterData: DataSortFilterModel) {
        var newFilterData = filterData
        if let text = filterData.filterText {
            let filterText = NSString(string: text)
            newFilterData.filterText = filterText.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }

        filterModels[filterData.type.rawValue] = newFilterData
    }
}
