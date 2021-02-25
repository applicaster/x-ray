//
//  DefaultLoggerViewController.swift
//  Xray
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class DefaultLoggerViewController: LoggerViewBaseController {
    override func prepareLogger() {
        title = "Logger"

        let activeSink = Xray.sharedInstance.getSink("InMemorySink") as? InMemory
        self.activeSink = activeSink
        if let events = activeSink?.events {
            originalDataSource = events
            filterDataSource()
        }
    }
}
