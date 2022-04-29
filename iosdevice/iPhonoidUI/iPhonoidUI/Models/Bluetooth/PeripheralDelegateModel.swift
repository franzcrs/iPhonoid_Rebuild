//  
//  PeripheralDelegateModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/23
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI
import CoreBluetooth

final class PeripheralDelegateModel: NSObject, CBPeripheralDelegate {
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        print("Discovered Services: \(services)")
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics:\n" +
              "List of characteristics:\n")
        
        for characteristic in characteristics {
            print(characteristic.uuid)
        }
    }
}
