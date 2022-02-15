//  
//  FaceViewModel.swift
//  
//  Class that represents the abstraction of data that FaceView is going to manage
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/12
//  Copyright © 2022. All rights reserved.
//  

import Foundation
import SwiftUI

final class FaceViewData: ObservableObject{
    
    @Published var rightEyeState = EyeModel()
    @Published var leftEyeState = EyeModel()
    
//    @Published var rightEyeClosed: Bool = false
//    @Published var leftEyeClosed: Bool = false
}
