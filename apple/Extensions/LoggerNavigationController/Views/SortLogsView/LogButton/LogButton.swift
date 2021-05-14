//
//  LogButton.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 9/9/20.
//

import Foundation
import XrayLogger

class LogButton: UIButton {
    let backgroundDefaultColor = UIColor(red: 250 / 255,
                                         green: 250 / 255,
                                         blue: 250 / 255,
                                         alpha: 1)
    var logLevel: LogLevel? {
        didSet {
            setTitle(logLevel?.toString(), for: .normal)
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = backgroundDefaultColor
            setTitleColor(UIColor.gray, for: .normal)
            if let logLevel = logLevel,
                isSelected {
                setTitleColor(backgroundDefaultColor, for: .normal)
                backgroundColor = logLevel.toColor()
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = backgroundDefaultColor
        layer.cornerRadius = 10.0
        setTitleColor(UIColor.gray, for: .normal)
    }
}
