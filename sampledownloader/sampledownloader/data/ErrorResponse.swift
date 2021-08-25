//
//  ErrorResponse.swift
//  ErrorResponse
//
//  Created by Anna Zharkova on 19.08.2021.
//

import Foundation

enum ErrorType {
   case auth, network, tech, other
}

class ErrorResponse : Error {
    var message: String = ""
    var type = ErrorType.other

    
    init(message: String) {
        self.message = message
    }
    
    init(type: ErrorType) {
        self.type = type
    }
}
