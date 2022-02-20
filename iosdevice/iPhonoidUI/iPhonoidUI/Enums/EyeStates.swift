//  
//  EyeStates.swift
//  
//  Enum file of possible states of an Eye. To add more.
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/15
//  Copyright © 2022. All rights reserved.
//  

import Foundation

enum EyeState {
    case open
    case closed
    case happy
    case angry
    case sad
}

extension EyeState {
    public var ctrlPointsSymmetry: Bool {
        switch self{
            case .open, .closed, .happy:
                return true
            case .angry, .sad:
                return false
        }
    }
}
