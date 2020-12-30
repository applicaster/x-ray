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
        filterTypeLabel.roundCorners(radius: 5)

        if #available(iOS 13.0, *) {
            textField.overrideUserInterfaceStyle = .light
        }
        textField.delegate = self
        filterSwitcher.removeTarget(self,
                                    action: #selector(switchChanged),
                                    for: UIControl.Event.valueChanged)
    }

    func updateCellData(filterData: DataSortFilterModel) {
        self.filterData = filterData
        filterSwitcher.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        filterTypeLabel.text = filterData.type.toString()
        filterSwitcher.isOn = filterData.isEnabled
        updateUI()
    }

    func updateUI() {
        let labelEnabledColor = UIColor(red: 90 / 255, green: 125 / 255, blue: 166 / 255, alpha: 1)
        let labelDisabledColor = UIColor(red: 121 / 255, green: 140 / 255, blue: 151 / 255, alpha: 1)

        filterTypeLabel.backgroundColor = filterData?.isEnabled ?? false ?
            labelEnabledColor : labelDisabledColor
        textField.text = filterData?.filterText
        textField.isEnabled = filterData?.isEnabled ?? false
    }

    @objc func switchChanged(sender: UISwitch) {
        filterData?.isEnabled = sender.isOn
        updateUI()
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
