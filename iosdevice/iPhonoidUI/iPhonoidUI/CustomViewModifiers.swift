//  
//  CustomViewModifiers.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/15
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct ForNewFullScreenRootView: ViewModifier {
    
    var AppStateInstance: AppStateModel
    
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(.container, edges: .all)
            .statusBar(hidden: true)
            .environmentObject(AppStateInstance)
    }
}
