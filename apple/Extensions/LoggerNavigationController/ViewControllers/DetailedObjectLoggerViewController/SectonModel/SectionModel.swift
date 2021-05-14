//
//  DetailedLoggerViewController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import MessageUI
import Reporter
import UIKit
import XrayLogger

struct SectionModel {
    var key: String = ""
    var value: String?
    var dataObject: Any?
}

class SectionDataSourceHelper {
    static func prepareDataSource(dataObject: Any?) -> [SectionModel] {
        if let dataDictionary = dataObject as? [String: Any] {
            return prepareDataSourceDictionary(dataDicionary: dataDictionary)
        } else if let dataArray = dataObject as? [Any] {
            return prepareDataSourceArray(dataArray: dataArray)
        }
        return []
    }

    static func prepareDataSourceDictionary(dataDicionary: [String: Any]) -> [SectionModel] {
        var newDataSource: [SectionModel] = []
        let noDataText = "No data availible"

        for (key, value) in dataDicionary {
            var sectionModel = SectionModel()
            sectionModel.key = key
            if let value = value as? [String] {
                sectionModel.dataObject = value
                sectionModel.value = "Items: \(value.count)"
            } else if let value = value as? [String: Any] {
                sectionModel.dataObject = value
                sectionModel.value = "Items: \(value.count)"
            } else if let value = value as? String {
                sectionModel.value = value.count > 0 ? value : noDataText
            } else if let value = value as? NSNumber {
                let stringValue = value.stringValue
                sectionModel.value = stringValue.count > 0 ? stringValue : noDataText
            }
            newDataSource.append(sectionModel)
        }
        return newDataSource
    }

    static func prepareDataSourceArray(dataArray: [Any]) -> [SectionModel] {
        var newDataSource: [SectionModel] = []
        let noDataText = "No data availible"

        for value in dataArray {
            var sectionModel = SectionModel()
            if let value = value as? [String] {
                sectionModel.value = "Items: \(value.count)"
                if value.count > 0 {
                    sectionModel.dataObject = value
                }
            } else if let value = value as? [String: Any] {
                sectionModel.value = "Items: \(value.count)"
                if value.count > 0 {
                    sectionModel.dataObject = value
                }
            } else if let value = value as? String {
                sectionModel.key = value.count > 0 ? value : noDataText
            } else if let value = value as? NSNumber {
                let stringValue = value.stringValue
                sectionModel.key = stringValue.count > 0 ? stringValue : noDataText
            }
            newDataSource.append(sectionModel)
        }
        return newDataSource
    }
}
