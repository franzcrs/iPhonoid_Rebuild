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
                .onChange(of: appState.bodyConnected){ _ in
                    print("onChange:\(appState.bodyConnected)")
                    if !appState.bodyConnected {
                        showSettings = true
                    }
                    else{
                        showSettings = false
                    }
                }
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        print("onAppear:\(appState.bodyConnected)")
//                        if !appState.bodyConnected {
//                            showSettings = true
//                        }
                        appState.bluetoothConnectivity = BluetoothConnectivityModel(connectionSuccessFlag: $appState.bodyConnected, scanTerminationFlag: $appState.scanCompleted)
                    }
                }) //TODO: Correct logic for displaying Settings view
//            SettingsView()
//                .interactiveDismissDisabled()
//                .environmentObject(appState)
//                .presentModallyAs(.popover, withTransition: .coverVertical, when: $showSettings)
            
                .presentModallyAs(.popover, withTransition: .coverVertical, when: $showSettings){
                    SettingsView()
                        .interactiveDismissDisabled()
                        .environmentObject(appState)
//                        .modifier(ForNewFullScreenRootView(AppStateInstance: appState))
                }
            Color.clear
                .frame(height: 33)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(AppStateModel(
                bodyConnectionInitialState: .init(initialValue: false))
            )
            .statusBar(hidden: true)
//            .environment(\.colorScheme, .dark)
    }
}
