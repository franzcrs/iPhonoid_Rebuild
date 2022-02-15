//  
//  EyeModel.swift
//  
//  Abstraction model of an Eye. Face ViewModel will created instances of this class for each eye.
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/15
//  Copyright © 2022. All rights reserved.
//  

import Foundation

final class EyeModel: ObservableObject{
    @Published var state: EyeState = .open
    @Published var intensity: Int = 5
    
    func updateState(to targetState: EyeState){
        state = targetState
    }
}
