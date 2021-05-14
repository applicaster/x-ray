//
//  Storable.swift
//  xray
//
//  Created by Anton Kononenko on 7/23/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public protocol Storable {
    func generateLogsToSingleFileUrl(_ completion: ((URL?) -> ())?)
    func deleteSingleFileUrl()
}
