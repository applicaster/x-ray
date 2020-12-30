//
//  FilterDataCell.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

class FilterDataCell: UITableViewCell {
    @IBOutlet weak var filterTypeButton: FilterButton!
    @IBOutlet weak var textField: UITextField!

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        contentView.frame = bounds.inset(by: padding)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
     
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        filterTypeButton.backgroundColor = UIColor.lightGray
        contentView.roundCorners(radius: 10)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 89 / 255, green: 127 / 255, blue: 166 / 255, alpha: 1).cgColor
        if #available(iOS 13.0, *) {
            textField.overrideUserInterfaceStyle = .light
        }
        textField.delegate = self
    }
}

extension FilterDataCell: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
