//
//  FileManager.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/21/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

class FileManagerHelper {
    @discardableResult class func saveToFile(str: String,
                                             url: URL,
                                             sync: Bool = false) -> Bool {
        let fileManager = FileManager.default

        let line = str + "\n"
        guard let data = line.data(using: String.Encoding.utf8) else { return false }

        do {
            if fileManager.fileExists(atPath: url.path) == false {
                let directoryURL = url.deletingLastPathComponent()
                if fileManager.fileExists(atPath: directoryURL.path) == false {
                    try fileManager.createDirectory(
                        at: directoryURL,
                        withIntermediateDirectories: true
                    )
                }
                fileManager.createFile(atPath: url.path, contents: nil)

                #if os(iOS) || os(watchOS)
                    var attributes = try fileManager.attributesOfItem(atPath: url.path)
                    attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                    try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                #endif
            }
            write(data: data,
                  to: url,
                  sync: sync)

            return true
        } catch {
            print("Can not save file in URL: \(url).")
            return false
        }
    }

    private class func write(data: Data,
                             to url: URL,
                             sync: Bool = false) {
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?
        coordinator.coordinate(writingItemAt: url, error: &error) { url in
            do {
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                if sync {
                    fileHandle.synchronizeFile()
                }
                fileHandle.closeFile()
            } catch {
                print("Can not write to file \(url).")
                return
            }
        }

        if let error = error {
            print("Failed writing file with error: \(String(describing: error))")
        }
    }

    public class func deleteLogFile(url: URL) -> Bool {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: url.path) == true else { return true }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            print("Can not remove file \(url).")
            return false
        }
    }

    public class func fileSizeInMB(forURL url: URL) -> Double? {
        let mbInBytes = 0.000001
        do {
            // return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attr[FileAttributeKey.size] as? Double {
                return fileSize * mbInBytes
            }

        } catch {
            print("Error: \(error)")
        }
        return nil
    }
}
