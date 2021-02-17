//
//  DataSortFilterHelper.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 12/30/20.
//

import Foundation
import XrayLogger

let filterModelsStorageKey = "xrayLoggerFilterModels"

class DataSortFilterHelper {
    static func filterDataSource(filterData: [DataSortFilterModel],
                                 allEvents: [Event]) -> [Event] {
        var filteredEvents: [Event] = allEvents
        for filterModel in filterData {
            filteredEvents = applyFilter(for: filterModel, events: filteredEvents)
        }
        return filteredEvents
    }

    static func applyFilter(for filterModel: DataSortFilterModel,
                            events: [Event]) -> [Event] {
        guard let filterText = filterModel.filterText?.lowercased(),
              filterText.count > 0 else {
            return events
        }

        switch filterModel.type {
        case .any:
            return filterAny(filterText: filterText,
                             events: events)
        case .subsystem:
            return filterSubsystem(filterText: filterText,
                                   events: events)
        case .category:
            return filterCategory(filterText: filterText,
                                  events: events)
        case .message:
            return filterMessage(filterText: filterText,
                                 events: events)
        }
    }

    static func filterAny(filterText: String,
                          events: [Event]) -> [Event] {
        return events.filter { (event) -> Bool in
            event.subsystem.lowercased().contains(filterText) ||
                event.category.lowercased().contains(filterText) ||
                event.message.lowercased().contains(filterText)
        }
    }

    static func filterSubsystem(filterText: String,
                                events: [Event]) -> [Event] {
        return events.filter { (event) -> Bool in
            event.subsystem.lowercased().contains(filterText)
        }
    }

    static func filterCategory(filterText: String,
                               events: [Event]) -> [Event] {
        return events.filter { (event) -> Bool in
            event.category.lowercased().contains(filterText)
        }
    }

    static func filterMessage(filterText: String,
                              events: [Event]) -> [Event] {
        return events.filter { (event) -> Bool in
            event.category.lowercased().contains(filterText)
        }
    }

    static func dataFromUserDefaults() -> [DataSortFilterModel] {
        guard let data = UserDefaults.standard.value(forKey: filterModelsStorageKey) as? [[String: Any]] else {
            return []
        }
        var filterModels: [DataSortFilterModel] = []
        for dataModel in data {
            if let model = DataSortFilterModel(data: dataModel) {
                filterModels.append(model)
            }
        }

        return filterModels
    }

    static func saveDataToUserDefaults(dataToSave: [DataSortFilterModel]) {
        let mapedDict = dataToSave.map({ $0.toDict() })

        UserDefaults.standard.set(mapedDict,
                                  forKey: filterModelsStorageKey)
    }
}
