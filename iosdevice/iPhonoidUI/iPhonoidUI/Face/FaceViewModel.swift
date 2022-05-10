//  
//  FaceViewModel.swift
//  
//  Abstraction Model of information and methods that FaceView is going to manage
//  
//  Version: 0.4
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/12
//  Copyright © 2022. All rights reserved.
//  

import Foundation
import SwiftUI

final class FaceViewModel: ObservableObject{
    
    @Published var rightEye = EyeModel(side: .right, state: .init(initialValue: .closed))
    @Published var leftEye = EyeModel(side: .left, state: .init(initialValue: .closed))
    @Published var mouth = MouthModel(state: .init(initialValue: .surprised))
    
    func sleep(){
        rightEye.updateState(to: .closed)
        leftEye.updateState(to: .closed)
        mouth.updateState(to: .surprised)
    }
    func happy(){
        rightEye.updateState(to: .happy)
        leftEye.updateState(to: .happy)
        mouth.updateState(to: .happy)
    }
    func sad(){
        rightEye.updateState(to: .sad)
        leftEye.updateState(to: .sad)
        mouth.updateState(to: .sad)
    }
    func angry(){
        rightEye.updateState(to: .angry)
        leftEye.updateState(to: .angry)
        mouth.updateState(to: .angry)
    }
}
