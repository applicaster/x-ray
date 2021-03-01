//
//  LoggerViewControllerDefault.swift
//  Xray
//
//  Created by Anton Kononenko on 7/20/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

class LoggerViewControllerDefault: LoggerViewControllerBase {
    @IBOutlet var sortLogsView: SortLogsView!

    override func prepareLogger() {
        title = "Logger"
        loggerType = .logger
        
        let activeSink = Xray.sharedInstance.getSink("InMemorySink") as? InMemory
        self.activeSink = activeSink
        if let events = activeSink?.events {
            originalDataSource = events
            filterDataSource()
        }
    }
    
    override func getSortParams() -> [Int : Bool] {
        return SortLogsHelper.dataFromUserDefaults()
    }
    
    
    override func initilizeSortData() {
        super.initilizeSortData()
        sortLogsView.delegate = self
        sortLogsView.initializeButtons(defaultStates: sortParams)
    }
    
    override func filterDataSourceByType() -> [Event] {
        return filteredDataSource.filter { (event) -> Bool in
            if let selected = sortParams[event.level.rawValue] {
                return selected
            }
            return false
        }
    }
    
    override func getCellIdentifier() -> String {
        return "LoggerCell"
    }
}

extension LoggerViewControllerDefault: SortLogsViewDelegate {
    func userPushButon(logType: LogLevel, selected: Bool) {
        sortParams[logType.rawValue] = selected
        SortLogsHelper.saveDataToUserDefaults(dataToSave: sortParams)
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
