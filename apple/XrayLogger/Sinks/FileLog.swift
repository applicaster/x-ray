//
//  FileLog.swift
//  xray
//
//  Created by Anton Kononenko on 7/17/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class FileLog: BaseSink {
    fileprivate var logsFolderURL: URL?
    fileprivate let singleLogsFileName = "XrayTxtLogs.txt"
    let fileManager = FileManager.default

    public init(folderName: String? = nil) {
        let folderName = folderName ?? "XrayTxtLogs"

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
    }

    override public func log(event: Event) {
        guard let logsFolderURL = logsFolderURL else {
            return
        }

        let fileUrl = logsFolderURL.appendingPathComponent("\(UUID().uuidString).txt")
        let message = formatter?.format(event: event) ?? event.message

        _ = FileManagerHelper.saveToFile(str: message,
                                         url: fileUrl,
                                         sync: false)
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
}

extension FileLog: Storable {
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

        var events: [String] = []
        for filePath in filePaths {
            let fileEvent = getEventLine(fromFile: filePath)
            events.append(fileEvent)
        }
        let eventsStringRepresentation = events.joined(separator: "\n")
        let singleLogsFileUrl = documentsFolder.appendingPathComponent(singleLogsFileName,
                                                                       isDirectory: false)
        let success = FileManagerHelper.saveToFile(str: eventsStringRepresentation,
                                                   url: singleLogsFileUrl,
                                                   sync: false)

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

    fileprivate func getEventLine(fromFile fileUrl: URL) -> String {
        do {
            let data = try Data(contentsOf: fileUrl,
                                options: .mappedIfSafe)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
