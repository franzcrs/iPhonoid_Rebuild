//  
//  PeripheralDelegateModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/23
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI
import CoreBluetooth

final class PeripheralDelegateModel: NSObject, CBPeripheralDelegate {
    
    @Binding private var characteristicsForInteraction: [CBCharacteristic]
    @Binding private var connectionSuccess: Bool
    
    init(characteristicsForInteractionList: Binding<[CBCharacteristic]>, connectionSuccessFlag: Binding<Bool>) {
        _characteristicsForInteraction = characteristicsForInteractionList
        _connectionSuccess = connectionSuccessFlag
        super.init()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(BluetoothModel.retrieveUUIDsOfCompatible(.characteristics), for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
//        print("Found \(characteristics.count) characteristics:\n" +
//              "List of characteristics:\n")
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify),characteristic.properties.contains(.read) {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    characteristicsForInteraction.insert(characteristic, at: 0)
                }
                else{
                    characteristicsForInteraction.append(characteristic)
                }
            }
//            print(characteristic.uuid)
        }
//        print(characteristicsForInteraction)
        connectionSuccess = true
    }
}
