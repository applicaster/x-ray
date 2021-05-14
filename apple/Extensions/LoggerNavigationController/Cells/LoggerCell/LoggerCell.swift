//
//  LoggerCell.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

public protocol LoggerCellProtocol {
    func updateCell(event: Event,
                    dateString: String)
}

class LoggerCell: UICollectionViewCell, LoggerCellProtocol {
    @IBOutlet weak var loggerTypeView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var subsystemLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logTypeLabel: UILabel!

    override func prepareForReuse() {
        messageLabel.text = ""
        subsystemLabel.text = ""
        dateLabel.text = ""
        loggerTypeView.backgroundColor = UIColor.clear
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 120)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }

    func updateCell(event: Event,
                    dateString: String) {
        roundCorners(radius: 10)
        messageLabel.text = event.message
        subsystemLabel.text = event.subsystem
        dateLabel.text = dateString
        loggerTypeView.backgroundColor = event.level.toColor()
        logTypeLabel.text = event.level.toString()
        logTypeLabel.textColor = event.level.toColor()
    }
}

