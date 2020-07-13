//
//  DefaultMessageFormatter.swift
//  xray
//
//  Created by Anton Kononenko on 7/13/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

class DefaultMessageFormatter: MessageFormatterProtocol {
    func format(template: String, prameters: [String: Any], otherArgs: Any...) -> String {
        var retVal = template
        for arg in otherArgs {
            retVal = retVal + "\(arg)"
        }
        return retVal
    }
}
