//  
//  iPhonoidUIApp.swift
//  
//  Application for the new iPhonoid developments, using SwiftUI
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

@main
struct iPhonoidUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var eyeClosed: Bool = false
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            EyeView(size: CGSize(width: 80, height: 280), closed: $eyeClosed)
                .frame(width: 100, height: 320)
                .background(Color.white)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
