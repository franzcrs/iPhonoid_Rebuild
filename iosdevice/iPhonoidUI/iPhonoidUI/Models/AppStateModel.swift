//  
//  AppStateModel.swift
//  
//  Representation Model of the state of information of the whole App
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import Foundation
import CoreBluetooth

final class AppStateModel: ObservableObject{
    
    @Published var bodyConnected: Bool
    @Published var scanCompleted: Bool
    @Published var bluetoothConnectivity: BluetoothConnectivityModel?
//    @Published var bluetoothConnectivity: BTConn?
    
    init(bodyConnectionInitialState: Published<Bool>){
        self._bodyConnected = bodyConnectionInitialState
        self._scanCompleted = .init(initialValue: false)
    }
}
