//  
//  ManagerDelegateModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.3
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/23
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI
import CoreBluetooth

public class ManagerDelegateModel: NSObject, CBCentralManagerDelegate {
    
    @Binding private var connectionSuccess: Bool
    @Binding private var scanTermination: Bool
    @Binding private var discoveredPeripherals: [String:PeripheralModel]
    @Binding private var connectedPeripheral: PeripheralModel
    @Binding private var characteristicsForInteraction: [CBCharacteristic]
    private var constrainToCompatiblePeripherals: Bool
//    private var compatiblePeripherals: [String: PeripheralUUIDsModel] = [:]
    
    init(connectionSuccessFlag: Binding<Bool>,
         scanTerminationFlag: Binding<Bool>,
         discoveredPeripheralsList: Binding<[String:PeripheralModel]>,
         connectedPeripheralReference: Binding<PeripheralModel>,
         characteristicsForInteractionList: Binding<[CBCharacteristic]>,
//         compatiblePeripheralsList: [String: PeripheralUUIDsModel]?
         compatibilityRestriction: Bool
    ) {
        _connectionSuccess = connectionSuccessFlag
        _scanTermination = scanTerminationFlag
        _discoveredPeripherals = discoveredPeripheralsList
        _connectedPeripheral = connectedPeripheralReference
        _characteristicsForInteraction = characteristicsForInteractionList
        constrainToCompatiblePeripherals = compatibilityRestriction
//        if compatiblePeripheralsList != nil {
//            compatiblePeripherals = compatiblePeripheralsList!
//        }
        super.init()
    }
    
//    private func retrieveUUIDsOfCompatibleServices() -> [CBUUID]? {
//        if compatiblePeripherals.isEmpty {
//            return nil
//        }
//        else {
//            var listOfUUIDs: [CBUUID] = []
//            compatiblePeripherals.forEach { _, device in
//                listOfUUIDs.append(contentsOf: device.serviceUUIDs)
//            }
//            return listOfUUIDs
//        }
//    }
    
    private func startScan(_ central: CBCentralManager) {
//        central.scanForPeripherals(withServices: serviceUUIDList, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        central.scanForPeripherals(withServices: constrainToCompatiblePeripherals
                                   ? BluetoothModel.retrieveUUIDsOfCompatible(.services)
                                   : nil,
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        /*
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            central.stopScan()
        })
         */
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Bluetooth: ")
        switch central.state {
            case .poweredOff:
                print("Is Powered Off.")
            case .poweredOn:
                print("Is Powered On.")
                if constrainToCompatiblePeripherals {
                    print("Scanning for compatible peripherals\n" +
                          "(List of Service UUIDs:")
                    BluetoothModel.retrieveUUIDsOfCompatible(.services).forEach { CBUUID in
                        print(CBUUID.uuidString)
                    }
                    print(")")
                }
                startScan(central)
            case .unsupported:
                print("Is Unsupported.")
            case .unauthorized:
                print("Is Unauthorized.")
            case .unknown:
                print("Unknown")
            case .resetting:
                print("Resetting")
            @unknown default:
                print("Error")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        discoveredPeripherals[peripheral.identifier.uuidString] = PeripheralModel(cbPeripheral: peripheral, rssi: RSSI, characteristicsForInteractionList: $characteristicsForInteraction, connectionSuccessFlag: $connectionSuccess)
        print("Peripheral Discovered: \(peripheral)")
        print("Identifier UUID: \(peripheral.identifier.uuidString)")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print("Advertisement Data : \(advertisementData)\n")
//        foundPeripheral = peripheral
//        foundPeripheral?.delegate = self
//        centralManager!.connect(foundPeripheral!, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = discoveredPeripherals[peripheral.identifier.uuidString]!
        connectedPeripheral.cbPeripheral?.discoverServices(BluetoothModel.retrieveUUIDsOfCompatible(.services))
        central.stopScan()
    }
}
