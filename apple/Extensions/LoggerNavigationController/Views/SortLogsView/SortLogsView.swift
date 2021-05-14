//
//  SortLogsView.swift
//  LoggerInfo
//
//  Created by Anton Kononenko on 9/9/20.
//

import UIKit
import XrayLogger

class SortLogsView: UIView {
    @IBOutlet var verboseButton: LogButton!
    @IBOutlet var debugButton: LogButton!
    @IBOutlet var infoButton: LogButton!
    @IBOutlet var warningButton: LogButton!
    @IBOutlet var errorButton: LogButton!

    weak var delegate: SortLogsViewDelegate?

    @IBAction func handleLogType(_ sender: LogButton) {
        sender.isSelected = !sender.isSelected
        if let logLevel = sender.logLevel {
            delegate?.userPushButon(logType: logLevel, selected: sender.isSelected)
        }
    }

    func initializeButtons(defaultStates: [Int: Bool]) {
        verboseButton.logLevel = LogLevel.verbose
        debugButton.logLevel = LogLevel.debug
        infoButton.logLevel = LogLevel.info
        warningButton.logLevel = LogLevel.warning
        errorButton.logLevel = LogLevel.error

        verboseButton.isSelected = SortLogsHelper.stateForLogLevel(logLevel: LogLevel.verbose,
                                                                   data: defaultStates)
        debugButton.isSelected = SortLogsHelper.stateForLogLevel(logLevel: LogLevel.debug,
                                                                 data: defaultStates)
        infoButton.isSelected = SortLogsHelper.stateForLogLevel(logLevel: LogLevel.info,
                                                                data: defaultStates)
        warningButton.isSelected = SortLogsHelper.stateForLogLevel(logLevel: LogLevel.warning,
                                                                   data: defaultStates)
        errorButton.isSelected = SortLogsHelper.stateForLogLevel(logLevel: LogLevel.error,
                                                                 data: defaultStates)
    }
}
