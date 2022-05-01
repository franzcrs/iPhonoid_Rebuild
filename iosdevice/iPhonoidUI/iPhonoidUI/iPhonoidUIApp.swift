//  
//  iPhonoidUIApp.swift
//  
//  Application for the new iPhonoid developments, using SwiftUI.
//  
//  Version: 0.5
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

@main
struct iPhonoidUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @ObservedObject var appState = AppStateModel(bodyConnectionInitialState: .init(initialValue: false))
    @ObservedObject var bluetooth = BluetoothModel(connectionSuccessFlag: .init(initialValue: false))
        
    var body: some Scene {
        WindowGroup {
            Group{
                if bluetooth.connectionSuccess {
                    FaceView()
                        .environmentObject(FaceViewModel())

                } else {
                    LoadingView()
                }
            }
            .modifier(ForNewFullScreenRootView(bluetoothModelInstance: bluetooth))
        }
    }
}
