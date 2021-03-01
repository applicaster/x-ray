//
//  LoggerNetworkRequestCell.swift
//  ExampleProject
//
//  Created by Alex Zchut on 2/28/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

class LoggerNetworkRequestCell: UICollectionViewCell, LoggerCellProtocol {
    @IBOutlet var loggerTypeView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var logTypeLabel: UILabel!

    override func prepareForReuse() {
        messageLabel.text = ""
        dateLabel.text = ""
        logTypeLabel.textColor = UIColor.white
        logTypeLabel.text = ""
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
        messageLabel.text = url(from: event)
        dateLabel.text = dateString

        if let info = networkRequestStatusCode(from: event) {
            loggerTypeView.backgroundColor = info.networkRequestStatusCode.toColor()
            
            if let statusDescription = info.httpStatusCode?.description {
                logTypeLabel.text = statusDescription
                logTypeLabel.textColor = info.networkRequestStatusCode.toColor()
            }
        }
    }
    
    fileprivate func url(from event: Event) -> String {
        return event.data?["url"] as? String ?? event.message.replacingOccurrences(of: "Network Request: ", with: "")
    }
    
    fileprivate func networkRequestStatusCode(from event: Event) -> (networkRequestStatusCode: NetworkRequestStatusCode,
                                                         httpStatusCode: HTTPStatusCode?)? {
        guard let statusCodeString = event.networkRequestStatusCode,
              let networkRequestStatusCode = NetworkRequestStatusCode(statusCode: statusCodeString),
              let httpStatusCode = HTTPStatusCode(rawValue: Int(statusCodeString) ?? 0) else {
            return (NetworkRequestStatusCode.x000, nil)
        }
        return (networkRequestStatusCode, httpStatusCode)
    }
}
