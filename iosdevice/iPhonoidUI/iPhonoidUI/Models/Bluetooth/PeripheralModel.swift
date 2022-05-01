//  
//  PeripheralModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/30
//  Copyright © 2022. All rights reserved.
//  

import CoreBluetooth

struct PeripheralModel: Identifiable {
    
    var id: UUID?
    var cbPeripheral: CBPeripheral?
    var rssi: NSNumber?
    var delegate: CBPeripheralDelegate?
    var name: String = "NoName"
    
    init(){
    }
    
    init(cbPeripheral: CBPeripheral, rssi: NSNumber) {
        self.id = UUID(uuidString: cbPeripheral.identifier.uuidString)
        self.cbPeripheral = cbPeripheral
        self.rssi = rssi
        self.delegate = PeripheralDelegateModel()
        self.cbPeripheral?.delegate = self.delegate
        if cbPeripheral.name != nil {
            self.name = cbPeripheral.name!
        }
    }
}
