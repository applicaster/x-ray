//
//  NetworkRequestsLoggerViewController.swift
//  Xray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class NetworkRequestsLoggerViewController: LoggerViewBaseController {

    override func prepareLogger() {
        title = "Network Requests"

        let activeSink = Xray.sharedInstance.getSink("InMemoryNetworkRequestsSink") as? InMemory
        self.activeSink = activeSink
        if let events = activeSink?.events {
            originalDataSource = events
            filterDataSource()
        }
    }
}
