//  
//  FaceViewModel.swift
//  
//  Class that represents the abstraction of data that FaceView is going to manage
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/12
//  Copyright © 2022. All rights reserved.
//  

import Foundation
import SwiftUI

final class FaceViewData: ObservableObject{
    
    @Published var rightEye = EyeModel(side: .right, state: .init(initialValue: .open))
    @Published var leftEye = EyeModel(side: .left, state: .init(initialValue: .open))
    @Published var mouth = MouthModel(state: .init(initialValue: .happy))
    
}
