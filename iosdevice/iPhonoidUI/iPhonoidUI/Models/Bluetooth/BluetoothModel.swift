//  
//  BluetoothModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/30
//  Copyright © 2022. All rights reserved.
//  

import Combine
import CoreBluetooth
import SwiftUI

class BluetoothModel: ObservableObject {
    
//    @Binding var connectionSuccess: Bool
    @Published var connectionSuccess: Bool
    @Published var scanTermination: Bool
    @Published var discoveredPeripherals: [String:PeripheralModel]
    @Published var connectedPeripheral: PeripheralModel
    
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
    
    init(connectionSuccessFlag: Published<Bool>) {
//    init(connectionSuccessFlag: Binding<Bool>) {
        _connectionSuccess = connectionSuccessFlag
        scanTermination = false
        discoveredPeripherals = [:]
        connectedPeripheral = PeripheralModel()
    }
    
    public func initialize(connectionSuccessFlag: Binding<Bool>,
                           scanTerminationFlag: Binding<Bool>,
                           discoveredPeripheralsList: Binding<[String:PeripheralModel]>,
                           connectedPeripheralReference: Binding<PeripheralModel>,
                           constrainToCompatiblePeripherals: Bool? = true) {
        
        let compatiblePeripheralsList = constrainToCompatiblePeripherals! ? Self.compatiblePeripherals : nil
        
        managerDelegate = ManagerDelegateModel(connectionSuccessFlag: connectionSuccessFlag, scanTerminationFlag: scanTerminationFlag, discoveredPeripheralsList: discoveredPeripheralsList, connectedPeripheralReference: connectedPeripheralReference, compatiblePeripheralsList: compatiblePeripheralsList)
        centralManager = CBCentralManager(delegate: managerDelegate, queue: nil)
    }
    
    public func connectTo(_ peripheral:PeripheralModel){
        centralManager?.connect(peripheral.cbPeripheral!, options: nil)
    }
    
}
