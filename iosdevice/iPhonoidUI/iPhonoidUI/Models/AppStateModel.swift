//  
//  AppStateModel.swift
//  
//  Representation Model of the state of information of the whole App
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import Foundation

final class AppStateModel: ObservableObject{
    
    @Published var btConnectionSuccessful: Bool
    
    init(btConnectionSuccess: Published<Bool>){
        self._btConnectionSuccessful = btConnectionSuccess
    }
    
}
