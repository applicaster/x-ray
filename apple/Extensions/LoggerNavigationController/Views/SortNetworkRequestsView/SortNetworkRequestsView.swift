//
//  SortNetworkRequestsView.swift
//  LoggerInfo
//
//  Created by Alex Zchut on 02/28/21.
//  Copyright © 2021 Applicaster. All rights reserved.
//

import UIKit
import XrayLogger

class SortNetworkRequestsView: UIView {
    @IBOutlet var button200: NetworkRequestsSortButton!
    @IBOutlet var button300: NetworkRequestsSortButton!
    @IBOutlet var button400: NetworkRequestsSortButton!
    @IBOutlet var button500: NetworkRequestsSortButton!

    weak var delegate: SortNetworkRequestsViewDelegate?

    @IBAction func handleStatusCode(_ sender: NetworkRequestsSortButton) {
        sender.isSelected = !sender.isSelected
        if let statusCode = sender.networkRequestStatusCode {
            delegate?.userPushButton(statusCode: statusCode, selected: sender.isSelected)
        }
    }

    func initializeButtons(defaultStates: [Int: Bool]) {
        button200.networkRequestStatusCode = .x200
        button300.networkRequestStatusCode = .x300
        button400.networkRequestStatusCode = .x400
        button500.networkRequestStatusCode = .x500

        button200.isSelected = SortNetworkRequestsHelper.stateForStatusCode(statusCode: .x200,
                                                                            data: defaultStates)
        button300.isSelected = SortNetworkRequestsHelper.stateForStatusCode(statusCode: .x300,
                                                                            data: defaultStates)
        button400.isSelected = SortNetworkRequestsHelper.stateForStatusCode(statusCode: .x400,
                                                                            data: defaultStates)
        button500.isSelected = SortNetworkRequestsHelper.stateForStatusCode(statusCode: .x500,
                                                                            data: defaultStates)
    }
}
