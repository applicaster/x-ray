//
//  SortNetworkRequestsHelper.swift
//  LoggerInfo
//
//  Created by Alex Zchut on 02/28/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import Foundation
import XrayLogger

let sortNetworkRequestsStorageKey = "xrayLoggerInfoNetworkRequestsSorter"

protocol SortNetworkRequestsViewDelegate: AnyObject {
    func userPushButton(statusCode: NetworkRequestStatusCode,
                        selected: Bool)
}

struct SortNetworkRequestsHelper {
    static func dataFromUserDefaults() -> [Int: Bool] {
        if let data = UserDefaults.standard.value(forKey: sortNetworkRequestsStorageKey) as? Data,
           let result = DataObject.loadContent(from: data) {
            return result
        } else {
            let newData: [Int: Bool] = [
                NetworkRequestStatusCode.x200.rawValue: false,
                NetworkRequestStatusCode.x300.rawValue: false,
                NetworkRequestStatusCode.x400.rawValue: false,
                NetworkRequestStatusCode.x500.rawValue: true,
            ]
            saveDataToUserDefaults(dataToSave: newData)
            return newData
        }
    }

    static func saveDataToUserDefaults(dataToSave: [Int: Bool]) {
        let dataObject = DataObject(content: dataToSave)
        guard let data = dataObject.archiveContent() else {
            return
        }

        UserDefaults.standard.set(data,
                                  forKey: sortNetworkRequestsStorageKey)
    }

    static func stateForStatusCode(statusCode: NetworkRequestStatusCode,
                                   data: [Int: Bool]) -> Bool {
        guard let isSelected = data[statusCode.rawValue] else {
            return false
        }
        return isSelected
    }
}
