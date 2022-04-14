//  
//  LoadingView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct LoadingView: View {
    
    @EnvironmentObject var appState: AppStateModel
    @State private var showSettings: Bool = false
//    @State private var anchorViewFrame: CGRect = CGRect()
    
    var body: some View {
        VStack() {
            Spacer()
            Text("Loading . . .")
                .font(.title).bold()
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        if !appState.btConnectionSuccessful {
                                showSettings = true
                        }
                    }
                })
            
            SettingsView()
                .interactiveDismissDisabled()
                .environmentObject(appState)
                .presentModallyAs(.popover, withTransition: .crossDissolve, when: $showSettings)
                 
//                .overlay(GeometryReader { geometryProxy in
//                        Color.clear
//                            .onAppear(perform: {
//                                anchorViewFrame = geometryProxy.frame(in: .global)
//                            })
//                            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
//                                anchorViewFrame = geometryProxy.frame(in: .global)
//                            })
//                            .presentModallyAsA(.popover, withTransition: .crossDissolve, when: $showSettings, appearingFrom: $anchorViewFrame){
//                                SettingsView()
//                                    .interactiveDismissDisabled()
//                                    .environmentObject(appState)
//                            }
//                    })
            
//                .presentModallyAs(.fullScreen, withTransition: .coverVertical, when: $showSettings){
//                    SettingsView()
//                        .interactiveDismissDisabled()
//                        /*.environmentObject(appState)*/
//                        .modifier(ForNewFullScreenRootView(AppStateInstance: appState))
//                }
            Color.clear
                .frame(height: 33)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(AppStateModel(
                btConnectionSuccess: .init(initialValue: false))
            )
            .statusBar(hidden: true)
    }
}
