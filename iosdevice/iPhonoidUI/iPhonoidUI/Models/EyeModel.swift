//  
//  EyeModel.swift
//  
//  Abstraction model of an Eye. Added initializer to specify the side of the body
//  the eye belongs to and an initial state. Face ViewModel will created instances
//  of this class for each eye.
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/15
//  Copyright © 2022. All rights reserved.
//  

import Foundation

final class EyeModel: ObservableObject{
    var side: Side
    @Published var state: EyeState
    @Published var intensity: Int = 5
    
    init(side: Side, state: Published<EyeState>){
        self.side = side
        self._state = state
    }
    
    func updateState(to targetState: EyeState){
        state = targetState
    }
}
