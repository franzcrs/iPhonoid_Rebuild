//  
//  ColorExtension.swift
//  
//  Extension for Color struct for creating colors from hexadecimal values
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/20
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

extension Color{
    init(hexR: Int, hexG: Int, hexB: Int) {
        assert(hexR >= 0 && hexR <= 255, "Invalid red component")
        assert(hexG >= 0 && hexG <= 255, "Invalid green component")
        assert(hexB >= 0 && hexB <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(hexR) / 255.0, green: CGFloat(hexG) / 255.0, blue: CGFloat(hexB) / 255.0, opacity: 1.0)
    }
    
    init(hex: Int) {
        self.init(
            hexR: (hex >> 16) & 0xFF,
            hexG: (hex >> 8) & 0xFF,
            hexB: hex & 0xFF
        )
    }
}
