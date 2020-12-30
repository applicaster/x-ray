//
//  LoggerNavigationController.swift
//  ExampleProject
//
//  Created by Anton Kononenko on 7/24/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit
public class LoggerNavigationController: UINavigationController {
    public static func loggerNavigationController() -> UINavigationController {
        let navController = UINavigationController(rootViewController: loggerViewController())
        return navController
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setViewControllers([LoggerNavigationController.loggerViewController()],
                           animated: false)
    }

    static func loggerViewController() -> LoggerViewController {
        let bundle = Bundle(for: Self.self)
        let loggerViewController = LoggerViewController(nibName: "LoggerViewController",
                                                        bundle: bundle)
        
        NSSetUncaughtExceptionHandler { (exception) in
           let stack = exception.callStackReturnAddresses
           print("Stack trace: \(stack)")
            }
        return loggerViewController
    }
}
