//  
//  BtPeripheralModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/23
//  Copyright © 2022. All rights reserved.
//  

import CoreBluetooth

public class BluetoothPeripheralModel: NSObject, ObservableObject {
    
    let cbPeripheral: CBPeripheral
    var rssi: NSNumber
    let delegate: CBPeripheralDelegate
    let name: String

    init(cbPeripheral: CBPeripheral, rssi: NSNumber) {
        self.cbPeripheral = cbPeripheral
        self.rssi = rssi
        self.delegate = PeripheralDelegateModel()
        self.cbPeripheral.delegate = self.delegate
        self.name = cbPeripheral.name ?? "NoName"
    }

    public func isConnected() -> Bool {
        self.cbPeripheral.state == CBPeripheralState.connected
    }

    public func discoverServices() {
        self.cbPeripheral.discoverServices(nil)
    }
}
