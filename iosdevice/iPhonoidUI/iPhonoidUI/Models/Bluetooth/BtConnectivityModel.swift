//  
//  BtConnectivityModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/19
//  Copyright © 2022. All rights reserved.
//  

import CoreBluetooth
import SwiftUI

class BluetoothConnectivityModel {
    
    
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
    
    
    private var centralManager: CBCentralManager!
    private var managerDelegate: CBCentralManagerDelegate!
    private var connectionSuccess: Binding<Bool>?
    public var discoveredPeripherals: [String : BluetoothPeripheralModel] = [:]
    private var scanTermination: Binding<Bool>?
//    @Published public var connectedPeripheral: BluetoothPeripheralModel?
    
    init() {
    }
    
    convenience init(connectionSuccessFlag: Binding<Bool>, scanTerminationFlag: Binding<Bool>, constrainToCompatiblePeripherals: Bool? = true) {
        self.init()
        connectionSuccess = connectionSuccessFlag
        scanTermination = scanTerminationFlag
        switch constrainToCompatiblePeripherals {
            case true:
                managerDelegate = ManagerDelegateModel(connectionSucessFlag: connectionSuccess!, scanTerminationFlag: scanTermination!, storeDiscoveredPeripheralClosure: { (peripheral: CBPeripheral, rssi: NSNumber) -> () in self.discoveredPeripherals[peripheral.identifier.uuidString] = BluetoothPeripheralModel(cbPeripheral: peripheral, rssi: rssi) }, purgeDiscoveredPeripheralsClosure: { self.discoveredPeripherals = [:] }, compatiblePeripheralsList: Self.compatiblePeripherals)
                centralManager = CBCentralManager(delegate: managerDelegate, queue: nil)
            default:
                managerDelegate = ManagerDelegateModel(connectionSucessFlag: connectionSuccess!, scanTerminationFlag: scanTermination!, storeDiscoveredPeripheralClosure: { (peripheral: CBPeripheral, rssi: NSNumber) -> () in  self.discoveredPeripherals[peripheral.identifier.uuidString] = BluetoothPeripheralModel(cbPeripheral: peripheral, rssi: rssi) }, purgeDiscoveredPeripheralsClosure: { self.discoveredPeripherals = [:] }, compatiblePeripheralsList: nil)
                centralManager = CBCentralManager(delegate: managerDelegate, queue: nil)
        }
    }
    
    public func connectTo(_ peripheral:BluetoothPeripheralModel){
        centralManager.connect(peripheral.cbPeripheral, options: nil)
    }
    
//    public mutating func addDiscoveredPeripheral(_ discoveredPeripheral: BluetoothPeripheralModel) -> Void {
//        discoveredPeripherals.append(discoveredPeripheral)
//    }
    
    /*
    private var btConnectionSucess: Binding<Bool>!
    private var compatiblePeripherals: [String: PeripheralUUIDsModel] = [:]
    
    private var foundPeripheral: CBPeripheral?
    private var customCharacteristic: CBCharacteristic?
    */
    public func dispatch(_ content: @escaping ()->Void){
        DispatchQueue.main.async(execute: content)
    }

//    public func disconnectFromDevice () {
//        if foundPeripheral != nil {
//            centralManager?.cancelPeripheralConnection(foundPeripheral!)
//        }
//    }
}
