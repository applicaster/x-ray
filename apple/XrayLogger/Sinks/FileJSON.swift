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
        let folderName = folderName ?? "XrayLogs"

        if let url = fileManager.urls(for: .documentDirectory,
                                      in: .userDomainMask).first {
            let dataPath = url.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: dataPath.absoluteString) {
                do {
                    try fileManager.createDirectory(atPath: dataPath.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                    fileURL = dataPath
                } catch {}
            }
        }

        super.init()
        updateApplicationVersionInUserDefaults()
    }

    override public func log(event: Event) {
        guard let url = fileURL else { return }
        deleteLogFilesIfNeeded(at: url)
        let dict = event.toDictionary()
        guard JSONSerialization.isValidJSONObject(dict) else {
            return
        }
        let fileUrl = url.appendingPathComponent("\(UUID().uuidString).json")
        do {
            let data = try JSONSerialization.data(withJSONObject: dict,
                                                  options: [])
            try data.write(to: fileUrl,
                           options: [])

        } catch {
            print(error)
        }
    }

    public func deleteLogsFolderContent() -> Bool {
        guard let url = fileURL,
              let filePaths = try? fileManager.contentsOfDirectory(at: url,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: []) else {
            return true
        }
        
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
        
        return true
    }

    private func deleteLogFilesIfNeeded(at path: URL) {
        if isFolderSizeLimitRiched(at: path) == true {
            _ = deleteLogsFolderContent()

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
            _ = deleteLogsFolderContent()
        }

        UserDefaults(suiteName: defaultsSuite)?.setValue(newApplicationVersion,
                                                         forKey: defaultsAppVersionKey)
    }
}
