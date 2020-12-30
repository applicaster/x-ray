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

protocol FilterViewControllerDelegate: class {
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
        dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleEditMode(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing == true {
            toggleEditModeButton.title = "Finish reorder Mode"
        } else {
            toggleEditModeButton.title = "Reorder mode"
        }
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

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
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

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = filterModels[sourceIndexPath.row]
        filterModels.remove(at: sourceIndexPath.row)
        filterModels.insert(movedObject, at: destinationIndexPath.row)
    }
}

extension FilterViewController: FilterDataCellDelegate {
    func cellDidUpdated(filterData: DataSortFilterModel) {
        filterModels[filterData.type.rawValue] = filterData
    }
}
