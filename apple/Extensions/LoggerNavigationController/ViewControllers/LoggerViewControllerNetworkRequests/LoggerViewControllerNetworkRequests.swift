//
//  LoggerViewControllerNetworkRequests.swift
//  Xray
//
//  Created by Alex Zchut on 02/25/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class LoggerViewControllerNetworkRequests: LoggerViewControllerBase {
    @IBOutlet var sortNetworkRequestsView: SortNetworkRequestsView!

    override func prepareLogger() {
        title = "Network Requests"
        loggerType = .networkRequests

        let activeSink = Xray.sharedInstance.getSink("InMemoryNetworkRequestsSink") as? InMemory
        self.activeSink = activeSink
        if let events = activeSink?.events {
            originalDataSource = events
            filterDataSource()
        }
    }

    override func getSortParams() -> [Int: Bool] {
        return SortNetworkRequestsHelper.dataFromUserDefaults()
    }

    override func getCellIdentifier() -> String {
        return "LoggerNetworkRequestCell"
    }

    override func initilizeSortData() {
        super.initilizeSortData()
        sortNetworkRequestsView.delegate = self
        sortNetworkRequestsView.initializeButtons(defaultStates: sortParams)
    }

    override func filterDataSourceByType() -> [Event] {
        return filteredDataSource.filter { (event) -> Bool in
            if let statusCodeString = event.networkRequestStatusCode,
               let statusCode = NetworkRequestStatusCode(statusCode: statusCodeString),
               let selected = sortParams[statusCode.rawValue] {
                return selected
            }
            return false
        }
    }
}

extension LoggerViewControllerNetworkRequests: SortNetworkRequestsViewDelegate {
    func userPushButton(statusCode: NetworkRequestStatusCode, selected: Bool) {
        sortParams[statusCode.rawValue] = selected
        SortNetworkRequestsHelper.saveDataToUserDefaults(dataToSave: sortParams)
        reloadCollectionViewWithFilters()
    }

    func reloadCollectionViewWithFilters() {
        let newFilteredDataSource = filterDataSourceByType()
        if filteredDataSourceByType != newFilteredDataSource {
            filteredDataSourceByType = newFilteredDataSource
            collectionView.reloadData()
            if filteredDataSourceByType.count > 0 {
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                            at: .top,
                                            animated: false)
            }
        }
    }
}
