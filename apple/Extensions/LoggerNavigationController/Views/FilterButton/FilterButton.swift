//
//  FilterButton.swift
//  FilterButton
//
//  Created by Anton Kononenko on 12/29/20.
//

import Foundation
import XrayLogger

class FilterButton: UIButton {
    let titleDefaultColor = UIColor(red: 250 / 255,
                                         green: 250 / 255,
                                         blue: 250 / 255,
                                         alpha: 1)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerRadius = 10.0
        setTitleColor(titleDefaultColor, for: .normal)

    }
}
