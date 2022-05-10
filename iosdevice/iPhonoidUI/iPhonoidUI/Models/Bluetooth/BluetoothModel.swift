//  
//  BluetoothModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/30
//  Copyright © 2022. All rights reserved.
//  

import Combine
import CoreBluetooth
import SwiftUI

class BluetoothModel: ObservableObject {
    
    @Published var connectionSuccess: Bool
    @Published var scanTermination: Bool
    @Published var discoveredPeripherals: [String:PeripheralModel]
    @Published var connectedPeripheral: PeripheralModel
    @Published var characteristicsForInteraction: [CBCharacteristic]
    
    private var centralManager: CBCentralManager?
    private var managerDelegate: CBCentralManagerDelegate?
    
    /**
     Developer-set list of compatible peripherals.
     Add the peripherals you wish the app to search for
     */
    static let compatiblePeripherals: [String : PeripheralUUIDsModel] =
    [
        "HM10": PeripheralUUIDsModel(
            serviceUUIDs: [CBUUID(string:"0000FFE0-0000-1000-8000-00805F9B34FB")],
            characteristicUUIDs: [CBUUID(string:"0000FFE1-0000-1000-8000-00805F9B34FB")])
    ]
    
    enum BluetoothAttributeType {
        case services
        case characteristics
    }
    
    static public func retrieveUUIDsOfCompatible(_ attribute: BluetoothAttributeType) -> [CBUUID] {
        var listOfUUIDs: [CBUUID] = []
        switch attribute {
            case .services:
                compatiblePeripherals.forEach { _, device in
                    listOfUUIDs.append(contentsOf: device.serviceUUIDs)
                }
            case .characteristics:
                compatiblePeripherals.forEach { _, device in
                    listOfUUIDs.append(contentsOf: device.characteristicUUIDs)
                }
        }
        return listOfUUIDs
    }
    
    init(connectionSuccessFlag: Published<Bool>) {
        _connectionSuccess = connectionSuccessFlag
        scanTermination = false
        discoveredPeripherals = [:]
        connectedPeripheral = PeripheralModel()
        characteristicsForInteraction = []
    }
    
    public func initialize(connectionSuccessFlag: Binding<Bool>,
                           scanTerminationFlag: Binding<Bool>,
                           discoveredPeripheralsList: Binding<[String:PeripheralModel]>,
                           connectedPeripheralReference: Binding<PeripheralModel>,
                           characteristicsForInteractionList: Binding<[CBCharacteristic]>,
                           constrainToCompatiblePeripherals: Bool? = true) {
        
//        let compatiblePeripheralsList = constrainToCompatiblePeripherals! ? Self.compatiblePeripherals : nil
        
        managerDelegate = ManagerDelegateModel(connectionSuccessFlag: connectionSuccessFlag, scanTerminationFlag: scanTerminationFlag, discoveredPeripheralsList: discoveredPeripheralsList, connectedPeripheralReference: connectedPeripheralReference, characteristicsForInteractionList: characteristicsForInteractionList, compatibilityRestriction: constrainToCompatiblePeripherals!)
        centralManager = CBCentralManager(delegate: managerDelegate, queue: nil)
    }
    
    public func stopScanning() {
        centralManager?.stopScan()
    }
    
    public func connectTo(_ peripheral:PeripheralModel){
        if connectedPeripheral.cbPeripheral != nil {
            centralManager?.cancelPeripheralConnection(connectedPeripheral.cbPeripheral!)
//            characteristicsForInteraction.removeAll()
        }
        centralManager?.connect(peripheral.cbPeripheral!, options: nil)
    }
    
    public func sendCommand(of7chars command: String, endChar: Character? = "\r", writingType: CBCharacteristicWriteType? = .withoutResponse) {
        if let connectedCBPeripheral = connectedPeripheral.cbPeripheral {
            if (command.count == 7){
                var extendedCommand = command
                extendedCommand.append(endChar!)
                var securedWritingtype: CBCharacteristicWriteType
                switch writingType {
                    case .withoutResponse:
                        securedWritingtype =
                        characteristicsForInteraction[0].properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
                    default:
                        securedWritingtype = characteristicsForInteraction[0].properties.contains(.write) ? .withResponse : .withoutResponse
                }
                connectedCBPeripheral.writeValue(
                    extendedCommand.data(using: .ascii)!,
                    for: characteristicsForInteraction[0],
                    type: securedWritingtype
                )
            }
            else{
                print("Command does not have 7 characters");
            }
        }
    }
}
