//  
//  PeripheralUUIDsModel.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/21
//  Copyright © 2022. All rights reserved.
//  

import Foundation
import CoreBluetooth

struct PeripheralUUIDsModel {
    var serviceUUIDs: [CBUUID]
    var characteristicUUIDs: [CBUUID]
}
