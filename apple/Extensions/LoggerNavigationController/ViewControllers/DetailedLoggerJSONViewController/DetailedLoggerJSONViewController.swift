//
//  DetailedLoggerJSONViewController.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Reporter
import UIKit
import XrayLogger

class DetailedLoggerJSONViewController: DetailedLoggerBaseViewController {
    @IBOutlet weak var jsonTextView: UITextView!

    override func prepareUI() {
        super.prepareUI()
        if let prettyPrintedJson = event?.toJSONString(options: .prettyPrinted) {
            jsonTextView.text = prettyPrintedJson
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Single Log JSON"
        prepareUI()
    }
}
