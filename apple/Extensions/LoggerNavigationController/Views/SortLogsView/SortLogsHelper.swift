//
//  LoggerViewCollectionFlowLayout.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 9/9/20.
//

import Foundation
import XrayLogger

let sortLogsStorageKey = "xrayLoggerInfoLogsSorter"

protocol SortLogsViewDelegate: class {
    func userPushButon(logType: LogLevel,
                       selected: Bool)
}

struct SortLogsHelper {
    static func dataFromUserDefaults() -> [Int: Bool] {
        if let data = UserDefaults.standard.value(forKey: sortLogsStorageKey) as? Data,
           let result = DataObject.loadContent(from: data) {
            return result
        } else {
            let newData: [Int: Bool] = [
                LogLevel.verbose.rawValue: true,
                LogLevel.debug.rawValue: true,
                LogLevel.info.rawValue: true,
                LogLevel.warning.rawValue: true,
                LogLevel.error.rawValue: true,
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
                                  forKey: sortLogsStorageKey)
    }

    static func stateForLogLevel(logLevel: LogLevel,
                                 data: [Int: Bool]) -> Bool {
        guard let isSelected = data[logLevel.rawValue] else {
            return false
        }
        return isSelected
    }
}

struct DataObject: Codable {
    var content: [Int: Bool]

    func archiveContent() -> Data? {
        var retValue: Data?
        do {
            retValue = try JSONEncoder().encode(self)
        }
        catch {
            // do nothing
        }
        return retValue
    }

    static func loadContent(from unarchivedObject: Data) -> [Int: Bool]? {
        var retValue: [Int: Bool]?

        do {
            let object = try JSONDecoder().decode(DataObject.self, from: unarchivedObject)
            retValue = object.content
        }
        catch {
            // do nothing
        }

        return retValue
    }
}
