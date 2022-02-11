//  
//  Errors.swift
//  
//  Enum file to list errors
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/08
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

enum DeveloperError: Error {
    // Throw when input of function is invalid
    case invalidInput(additionalMsg: String)
}

extension DeveloperError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .invalidInput(let message):
                return NSLocalizedString("Invalid Input. \(message)", comment: "Expected a value of a determined type")
        }
    }
}
