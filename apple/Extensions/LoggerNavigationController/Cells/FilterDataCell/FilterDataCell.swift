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
    @IBOutlet weak var filterTypeButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var filterSwitcher: UISwitch!

    var filterData: DataSortFilterModel?
    weak var delegate: FilterDataCellDelegate?

    var isFilterEnabled: Bool {
        return filterSwitcher.isOn
    }

    deinit {
        delegate = nil
        filterSwitcher.removeTarget(self,
                                    action: #selector(switchChanged),
                                    for: UIControl.Event.valueChanged)
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
        filterTypeButton.roundCorners(radius: 5)

        if #available(iOS 13.0, *) {
            textField.overrideUserInterfaceStyle = .light
        }
        textField.delegate = self
        filterSwitcher.removeTarget(self,
                                    action: #selector(switchChanged),
                                    for: UIControl.Event.valueChanged)
    }

    func updateCellData(filterData: DataSortFilterModel) {
        filterSwitcher.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        filterTypeButton.setTitle(filterData.type.toString(), for: .normal)
        textField.text = filterData.filterText
        filterSwitcher.isOn = filterData.isEnabled
        self.filterData = filterData
    }

    @objc func switchChanged(sender: UISwitch) {
        filterData?.isEnabled = sender.isOn
        notifyViewController()
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
