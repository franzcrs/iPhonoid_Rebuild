//  
//  iPhonoidUIApp.swift
//  
//  Application for the new iPhonoid developments, using SwiftUI.
//  
//  Version: 0.3
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

@main
struct iPhonoidUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup {
            FaceView()
                .environmentObject(FaceViewModel())
                .ignoresSafeArea(.container, edges: .all)
                .statusBar(hidden: true)
        }
    }
}
