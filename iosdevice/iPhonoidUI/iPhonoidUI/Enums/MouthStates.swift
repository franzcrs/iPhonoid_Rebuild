//  
//  MouthStates.swift
//  
//  Enum file of possible states of a mouth. To add more.
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/20
//  Copyright © 2022. All rights reserved.
//  

enum MouthState {
    case smiling
    case happy
    case sad
    case angry
    case surprised
}

extension MouthState{
    var strokesOverlap: Bool {
        switch self{
            case .smiling, .sad, .angry:
                return true
            case .happy, .surprised:
                return false
        }
    }
}
