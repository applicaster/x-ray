//
//  FilterDataCell.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

protocol FilterDataCellDelegate: class {
    func cellDidUpdated(filterData: DataSortFilterModel)
}

class FilterDataCell: UITableViewCell {
    @IBOutlet weak var filterTypeLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    var filterData: DataSortFilterModel?
    weak var delegate: FilterDataCellDelegate?

    deinit {
        delegate = nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        filterTypeLabel.roundCorners(radius: 5)

        if #available(iOS 13.0, *) {
            textField.overrideUserInterfaceStyle = .light
        }
        textField.delegate = self
    }

    func updateCellData(filterData: DataSortFilterModel) {
        self.filterData = filterData
        filterTypeLabel.text = filterData.type.toString()
        let labelColor = UIColor(red: 90 / 255, green: 125 / 255, blue: 166 / 255, alpha: 1)
        filterTypeLabel.backgroundColor = labelColor
        textField.text = filterData.filterText
    }

    func notifyViewController() {
        if let filterData = filterData {
            delegate?.cellDidUpdated(filterData: filterData)
        }
    }
}

extension FilterDataCell: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        filterData?.filterText = textField.text
        notifyViewController()
    }
}
