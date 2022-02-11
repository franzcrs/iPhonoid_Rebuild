//  
//  UIAttributesManagement.swift
//  
//  File for strucutures that provide methods that amanage the User interface general attributes
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/08
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct DisplayConventionalDimensions {
    func width() -> CGFloat {
        return UIScreen.main.fixedCoordinateSpace.bounds.width
    }
    func height() -> CGFloat {
        return UIScreen.main.fixedCoordinateSpace.bounds.height
    }
}

struct OrientationLock {
    /*
     Methods to call on .onAppear View modifier
     */
    
    let orientationMask: [UIInterfaceOrientation: UIInterfaceOrientationMask] = [
        UIInterfaceOrientation.portrait : .portrait,
        UIInterfaceOrientation.landscapeRight : .landscapeRight,
        UIInterfaceOrientation.portraitUpsideDown : .portraitUpsideDown,
        UIInterfaceOrientation.landscapeLeft : .landscapeLeft
    ]
    /**
     Changes and locks the orientation of the device
     - Parameter orientation: The target orientation to change to, of type UIInterfaceOrientation. Initialize it by writing `UIInterfaceOrientation.` and choosing a case of the enumeration excluding unknown.
     - Throws: `DeveloperError.invalidInput(additionalMsg: String)`
                if `orientation` is not among the four defined cases of `UIInterfaceOrientation`
     - Returns: Void
     */
    func lock(_ orientation: UIInterfaceOrientation!) -> Void {
        if let orientationMask = orientationMask[orientation] {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation") // Performing the corresponding rotation of screen
            AppDelegate.orientationLock = orientationMask // Locking the orientation
        } else {
            print(DeveloperError.invalidInput(additionalMsg: "No orientation lock performed").errorDescription!)
        }
    }
    
    func unlock() -> Void {
        AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
    }
}
