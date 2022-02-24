//  
//  MouthModel.swift
//  
//  Abstraction model of an Mouth. Added initializer to specify an initial state.
//  Face ViewModel will create an instance of this class.
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/20
//  Copyright © 2022. All rights reserved.
//  

import Foundation

final class MouthModel: ObservableObject{
    
    @Published var state: MouthState
    @Published var intensity: Int = 5
    
    init(state: Published<MouthState>){
        self._state = state
    }
    
    func updateState(to targetState: MouthState){
        state = targetState
    }
}
