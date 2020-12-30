//
//  DataSortFilterModel.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 12/30/20.
//

import Foundation

enum DataSortFilterModelKeys: String {
    case type
    case filterText
    case isEnabled
}

struct DataSortFilterModel:Equatable {
    let type: FilterTypes
    var filterText: String?
    var isEnabled: Bool

    init(type: FilterTypes,
         filterText: String? = nil,
         isEnabled: Bool) {
        self.type = type
        self.isEnabled = isEnabled
        self.filterText = filterText
    }

    init?(data: [String: Any]) {
        guard let rawType = data[DataSortFilterModelKeys.type.rawValue] as? Int,
              let type = FilterTypes(rawValue: rawType),
              let isEnabled = data[DataSortFilterModelKeys.isEnabled.rawValue] as? Bool else {
            return nil
        }

        self.type = type
        self.isEnabled = isEnabled
        filterText = data[DataSortFilterModelKeys.filterText.rawValue] as? String
    }

    func toDict() -> [String: Any] {
        var retVal: [String: Any] = [
            DataSortFilterModelKeys.type.rawValue: type.rawValue,
            DataSortFilterModelKeys.isEnabled.rawValue: isEnabled,
        ]

        if let filterText = filterText {
            retVal[DataSortFilterModelKeys.filterText.rawValue] = filterText
        }

        return retVal
    }
}
