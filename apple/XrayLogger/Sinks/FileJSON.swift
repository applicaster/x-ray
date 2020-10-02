//
//  FileJSON.swift
//  xray
//
//  Created by Anton Kononenko on 7/17/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class FileJSON: BaseSink, Storable {
    public private(set) var fileURL: URL?
    public var maxLogFileSizeInMB: Double? = 20
    public var deleteLogFileForNewAppVersion = true
    public var syncAfterEachWrite: Bool = false
    let fileManager = FileManager.default
    let defaultsSuite: String = "Xray_FileJSON"
    let defaultsAppVersionKey: String = "current_application_version"

    public init(fileName: String? = nil) {
        let fileName = fileName ?? "xray_file.json"

        if let url = fileManager.urls(for: .documentDirectory,
                                      in: .userDomainMask).first {
            fileURL = url.appendingPathComponent(fileName,
                                                 isDirectory: false)
        }

        super.init()
        updateApplicationVersionInUserDefaults()
    }

    func getEvents() -> [[String: Any]] {
        do {
            guard let url = fileURL else { return [] }
            let data = try Data(contentsOf: url,
                                options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data,
                                                              options: []) as? [[String: Any]]
            return jsonResult ?? []
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    override public func log(event: Event) {
        guard let url = fileURL else { return }
        deleteLogFileIfNeeded(url: url)
        let dict = event.toDictionary()
        guard JSONSerialization.isValidJSONObject(dict) else {
            return
        }
        var jsonEvents = getEvents()
        jsonEvents.append(dict)

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonEvents,
                                                  options: [])
            try data.write(to: url,
                           options: [])

        } catch {
            print(error)
        }
    }

    public func deleteLogFile() -> Bool {
        guard let url = fileURL else { return true }

        let result = FileManagerHelper.deleteLogFile(url: url)
        return result
    }

    private func deleteLogFileIfNeeded(url: URL) {
        if isFileSizeLimitRiched(url: url) == true {
            _ = deleteLogFile()
        }
    }

    private func isFileSizeLimitRiched(url: URL) -> Bool {
        guard let maxLogFileSizeInMB = maxLogFileSizeInMB,
            let fileSizeInMB = FileManagerHelper.fileSizeInMB(forURL: url),
            fileSizeInMB > maxLogFileSizeInMB else {
            return false
        }
        return true
    }

    private func applicationHasNewVersion() -> String? {
        guard
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else {
            return nil
        }

        let currentApplicationVersion = UserDefaults(suiteName: defaultsSuite)?.string(forKey: defaultsAppVersionKey)

        return currentApplicationVersion != appVersion ? appVersion : nil
    }

    private func updateApplicationVersionInUserDefaults() {
        guard let newApplicationVersion = applicationHasNewVersion()
        else {
            return
        }

        if deleteLogFileForNewAppVersion == true {
            _ = deleteLogFile()
        }

        UserDefaults(suiteName: defaultsSuite)?.setValue(newApplicationVersion,
                                                         forKey: defaultsAppVersionKey)
    }
}
