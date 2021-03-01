//
//  NetworkRequestSortButton.swift
//  LoggerInfo
//
//  Created by Alex Zchut on 02/28/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import Foundation
import XrayLogger

class NetworkRequestsSortButton: UIButton {
    let backgroundDefaultColor = UIColor(red: 250 / 255,
                                         green: 250 / 255,
                                         blue: 250 / 255,
                                         alpha: 1)
    var networkRequestStatusCode: NetworkRequestStatusCode? {
        didSet {
            setTitle("\(networkRequestStatusCode?.toString() ?? "")", for: .normal)
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = backgroundDefaultColor
            setTitleColor(UIColor.gray, for: .normal)
            if isSelected {
                setTitleColor(backgroundDefaultColor, for: .normal)
                backgroundColor = generateBackgroundColor()
            }
        }
    }

    func generateBackgroundColor() -> UIColor {
        guard let networkRequestStatusCode = networkRequestStatusCode else {
            return backgroundDefaultColor
        }

        return networkRequestStatusCode.toColor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = backgroundDefaultColor
        layer.cornerRadius = 10.0
        setTitleColor(UIColor.gray, for: .normal)
    }
}
