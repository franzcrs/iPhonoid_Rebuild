//  
//  ManagerDelegateModel.swift
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

public class ManagerDelegateModel: NSObject, CBCentralManagerDelegate {
    
    @Binding private var connectionSuccess: Bool
    @Binding private var scanTermination: Bool
    @Binding private var discoveredPeripherals: [String:PeripheralModel]
    @Binding private var connectedPeripheral: PeripheralModel
    private var compatiblePeripherals: [String: PeripheralUUIDsModel] = [:]
    
//    private let storePeripheral:(CBPeripheral, NSNumber) -> ()
//    private let purgePeripherals: () -> ()
//    var bluetoothqueue: DispatchQueue
    
//    init(connectionSucessFlag: Binding<Bool>, discoveredPeripheralsStack: Published<[String : BluetoothPeripheralModel]>, connectedPeripheralRef: Published<BluetoothPeripheralModel?>, compatiblePeripheralsList: [String: PeripheralUUIDsModel]?) {
    init(connectionSuccessFlag: Binding<Bool>,
         scanTerminationFlag: Binding<Bool>,
         discoveredPeripheralsList: Binding<[String:PeripheralModel]>,
         connectedPeripheralReference: Binding<PeripheralModel>,
         compatiblePeripheralsList: [String: PeripheralUUIDsModel]?
//        connectionSucessFlag: Binding<Bool>, scanTerminationFlag: Binding<Bool>, storeDiscoveredPeripheralClosure storeClosure: @escaping (CBPeripheral, NSNumber) -> (), purgeDiscoveredPeripheralsClosure purgeClosure: @escaping () -> (), compatiblePeripheralsList: [String: PeripheralUUIDsModel]?
    ) {
//        bluetoothqueue = queue
        _connectionSuccess = connectionSuccessFlag
        _scanTermination = scanTerminationFlag
        _discoveredPeripherals = discoveredPeripheralsList
        _connectedPeripheral = connectedPeripheralReference
        if compatiblePeripheralsList != nil {
            compatiblePeripherals = compatiblePeripheralsList!
        }
        super.init()
//        storePeripheral = storeClosure
//        purgePeripherals = purgeClosure
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
        central.scanForPeripherals(withServices: serviceUUIDList, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
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
        
        discoveredPeripherals[peripheral.identifier.uuidString] = PeripheralModel(cbPeripheral: peripheral, rssi: RSSI)
//        storePeripheral(peripheral, RSSI)
        print("Peripheral Discovered: \(peripheral)")
        print("Identifier UUID: \(peripheral.identifier.uuidString)")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print("Advertisement Data : \(advertisementData)\n")
//        foundPeripheral = peripheral
//        foundPeripheral?.delegate = self
//        centralManager!.connect(foundPeripheral!, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionSuccess = true
        connectedPeripheral = discoveredPeripherals[peripheral.identifier.uuidString]!
//        foundPeripheral?.discoverServices(nil)
    }
}
