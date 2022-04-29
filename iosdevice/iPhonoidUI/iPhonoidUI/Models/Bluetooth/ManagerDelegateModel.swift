//  
//  ManagerDelegateModel.swift
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

public class ManagerDelegateModel: NSObject, CBCentralManagerDelegate {
    
    
    
    private var connectionSuccess: Binding<Bool>
    private var scanTermination: Binding<Bool>
    private let storePeripheral:(CBPeripheral, NSNumber) -> ()
    private let purgePeripherals: () -> ()
    private var compatiblePeripherals: [String: PeripheralUUIDsModel] = [:]
//    var discoveredPeripherals: [String : BluetoothPeripheralModel]
//    @Published private var connectedPeripheral: BluetoothPeripheralModel?
    
//    init(connectionSucessFlag: Binding<Bool>, discoveredPeripheralsStack: Published<[String : BluetoothPeripheralModel]>, connectedPeripheralRef: Published<BluetoothPeripheralModel?>, compatiblePeripheralsList: [String: PeripheralUUIDsModel]?) {
    init(connectionSucessFlag: Binding<Bool>, scanTerminationFlag: Binding<Bool>, storeDiscoveredPeripheralClosure storeClosure: @escaping (CBPeripheral, NSNumber) -> (), purgeDiscoveredPeripheralsClosure purgeClosure: @escaping () -> (), compatiblePeripheralsList: [String: PeripheralUUIDsModel]?) {
        connectionSuccess = connectionSucessFlag
        scanTermination = scanTerminationFlag
        storePeripheral = storeClosure
        purgePeripherals = purgeClosure
//        discoveredPeripherals = discoveredPeripheralsStack
        if compatiblePeripheralsList != nil {
            compatiblePeripherals = compatiblePeripheralsList!
        }
        super.init()
    }
    
    private func retrieveUUIDsOfCompatibleServices() -> [CBUUID]? {
        if compatiblePeripherals.isEmpty {
            return nil
        }
        else {
            var listOfUUIDs: [CBUUID] = []
            compatiblePeripherals.forEach { _, device in
                listOfUUIDs.append(contentsOf: device.serviceUUIDs)
            }
            return listOfUUIDs
        }
    }
    
    private func startScan(_ central: CBCentralManager) {
        let serviceUUIDList = retrieveUUIDsOfCompatibleServices()
//        discoveredPeripherals = [:]
        purgePeripherals()
//        print(serviceUUIDList)
        central.scanForPeripherals(withServices: serviceUUIDList, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            central.stopScan()
//            print(self.discoveredPeripherals)
//            self.discoveredPeripherals.forEach { id, device in
//                print(device.cbPeripheral.identifier.uuidString)
//            }
            self.connectionSuccess.wrappedValue = false
//            self.scanCompleted.wrappedValue = false
        })
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Bluetooth: ")
        switch central.state {
            case .poweredOff:
                print("Is Powered Off.")
            case .poweredOn:
                print("Is Powered On.")
                if !(compatiblePeripherals.isEmpty) {
                    print("Scanning for compatible peripherals\n" +
                          "(List of Service UUIDs:")
                    compatiblePeripherals.forEach { _, device in
                        for service in device.serviceUUIDs {
                            print("\(service.uuidString)")
                        }
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
        
//        discoveredPeripherals[peripheral.identifier.uuidString] = BluetoothPeripheralModel(cbPeripheral: peripheral, rssi: RSSI)
        storePeripheral(peripheral, RSSI)
        
        print("Peripheral Discovered: \(peripheral)")
        print("Identifier UUID: \(peripheral.identifier.uuidString)")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print("Advertisement Data : \(advertisementData)\n")
        
//        centralManager!.stopScan()
//        foundPeripheral = peripheral
//        foundPeripheral?.delegate = self
//        centralManager!.connect(foundPeripheral!, options: nil)
    }
    
//    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        btConnectionSucess.wrappedValue = true
//        connectedPeripheral = discoveredPeripherals[peripheral.identifier.uuidString]
////        foundPeripheral?.discoverServices(nil)
//    }
}
