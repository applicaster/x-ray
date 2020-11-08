//
//  FileJSON.swift
//  xray
//
//  Created by Anton Kononenko on 7/17/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class FileJSON: BaseSink {
    fileprivate var logsFolderURL: URL?
    fileprivate let singleLogsFileName = "XrayJsonLogs.json"
    public var maxLogFileSizeInMB: Double? = 20
    public var deleteLogsFolderContentForNewAppVersion = true
    public var syncAfterEachWrite: Bool = false
    let fileManager = FileManager.default
    let defaultsSuite: String = "Xray_FileJSON"
    let defaultsAppVersionKey: String = "current_application_version"
    var cleanLogfileEvent: Event {
        return Event(category: "",
                     subsystem: "Sink.FileJSON",
                     timestamp: UInt(Date().timeIntervalSince1970),
                     level: .verbose,
                     message: "Events log cleaned",
                     data: nil,
                     context: nil,
                     exception: nil)
    }

    public init(folderName: String? = nil) {
        let folderName = folderName ?? "XrayJsonLogs"

        if let url = fileManager.urls(for: .documentDirectory,
                                      in: .userDomainMask).first {
            let dataPath = url.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: dataPath.absoluteString) {
                do {
                    try fileManager.createDirectory(atPath: dataPath.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                    logsFolderURL = dataPath
                } catch {}
            }
        }

        super.init()
        updateApplicationVersionInUserDefaults()
    }

    override public func log(event: Event) {
        guard let logsFolderURL = logsFolderURL else {
            return
        }
        deleteLogFilesIfNeeded(at: logsFolderURL)

        let dict = event.toDictionary()
        guard JSONSerialization.isValidJSONObject(dict) else {
            return
        }
        let fileUrl = logsFolderURL.appendingPathComponent("\(UUID().uuidString).json")
        do {
            let data = try JSONSerialization.data(withJSONObject: dict,
                                                  options: [])
            try data.write(to: fileUrl,
                           options: [])

        } catch {
            print(error)
        }
    }

    public func deleteLogsFolderContent(at path: URL) {
        guard let filePaths = try? fileManager.contentsOfDirectory(at: path,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: []) else {
            return
        }

        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }

    private func deleteLogFilesIfNeeded(at path: URL) {
        if isFolderSizeLimitRiched(at: path) {
            deleteLogsFolderContent(at: path)

            // save event of log file cleanup
            log(event: cleanLogfileEvent)
        }
    }

    private func isFolderSizeLimitRiched(at path: URL) -> Bool {
        guard let maxLogFileSizeInMB = maxLogFileSizeInMB,
            let fileSizeInMB = FileManagerHelper.fileSizeInMB(forURL: path),
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

        if deleteLogsFolderContentForNewAppVersion == true {
            guard let logsFolderURL = logsFolderURL else {
                return
            }
            deleteLogsFolderContent(at: logsFolderURL)
        }

        UserDefaults(suiteName: defaultsSuite)?.setValue(newApplicationVersion,
                                                         forKey: defaultsAppVersionKey)
    }
}

extension FileJSON: Storable {
    public func generateLogsToSingleFileUrl(_ completion: ((URL?) -> Void)?) {

        guard let logsFolderURL = logsFolderURL,
            let documentsFolder = fileManager.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first,
            let filePaths = try? fileManager.contentsOfDirectory(at: logsFolderURL,
                                                                 includingPropertiesForKeys: nil,
                                                                 options: []) else {
            completion?(nil)
            return
        }

        var events: [[String: Any]] = []
        for filePath in filePaths {
            let fileEvent = getEvent(fromFile: filePath)
            events.append(fileEvent)
        }

        let singleLogsFileUrl = documentsFolder.appendingPathComponent(singleLogsFileName,
                                                                       isDirectory: false)
        var success = false
        do {
            let data = try JSONSerialization.data(withJSONObject: events,
                                                  options: [])
            try data.write(to: singleLogsFileUrl,
                           options: [])
            success = true

        } catch {
            print(error)
        }

        completion?(success ? singleLogsFileUrl : nil)
    }
    
    public func deleteSingleFileUrl() {
        guard let documentsFolder = fileManager.urls(for: .documentDirectory,
                                                     in: .userDomainMask).first else {
            return
        }
        let singleLogsFileUrl = documentsFolder.appendingPathComponent(singleLogsFileName,
                                                                       isDirectory: false)
        _ = FileManagerHelper.deleteLogFile(url: singleLogsFileUrl)
    }

    fileprivate func getEvent(fromFile fileUrl: URL) -> [String: Any] {
        do {
            let data = try Data(contentsOf: fileUrl,
                                options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data,
                                                              options: []) as? [String: Any]
            return jsonResult ?? [:]
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }
}
