//
//  LoggerNavigationController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/24/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit
class LoggerNavigationController: UINavigationController {
    static func loggerNavigationController() -> UINavigationController {
        let loggerViewController = LoggerViewController(nibName: "LoggerViewController",
                                                        bundle: nil)
        return UINavigationController(rootViewController: loggerViewController)
    }
}
