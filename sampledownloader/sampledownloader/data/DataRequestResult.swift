//
//  Request.swift
//  Request
//
//  Created by Anna Zharkova on 19.08.2021.
//

import Foundation

enum DataRequestResult {
    case success(Any?)
    case failure(Error)
}

typealias CompletionHandler = ((_ result: DataRequestResult) -> Void)
