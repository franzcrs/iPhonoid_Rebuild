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
    
//    @State private var eyeClosed: Bool = false
    
    var body: some Scene {
        WindowGroup {
            FaceView()
                .environmentObject(FaceViewData())
//            EyeView(size: CGSize(width: 80, height: 280), closed: $eyeClosed)
//            EyeView(height: 280, closed: $eyeClosed)
//                .foregroundColor(.black)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.white)
                .ignoresSafeArea(.container, edges: .all)
                .statusBar(hidden: true)
        }
    }
}
