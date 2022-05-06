//  
//  LoadingView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.4
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct LoadingView: View {
    
    @EnvironmentObject var bluetooth: BluetoothModel
    @State private var showSettings: Bool = false
    
    var body: some View {
        VStack() {
            Spacer()
            Text("Loading . . .")
                .font(.title).bold()
            Color.clear
                .frame(height: 33)
        }
        .sheet(isPresented: $showSettings, onDismiss: nil, content: {
            SettingsView()
                .interactiveDismissDisabled()
                .modifier(ForNewFullScreenRootView(bluetoothModelInstance: bluetooth))
        })
        .onChange(of: bluetooth.connectionSuccess){ _ in
            print("onChange> bluetooth.connectionSuccess: \(bluetooth.connectionSuccess)")
            if !bluetooth.connectionSuccess {
               showSettings = true
            }
            else{
                showSettings = false
            }
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now()){
                if !bluetooth.connectionSuccess {
                    showSettings = true
                }
                print("onAppear> bluetooth.connectionSuccess: \(bluetooth.connectionSuccess)")
                bluetooth.initialize(connectionSuccessFlag: $bluetooth.connectionSuccess, scanTerminationFlag: $bluetooth.scanTermination, discoveredPeripheralsList: $bluetooth.discoveredPeripherals, connectedPeripheralReference: $bluetooth.connectedPeripheral, characteristicsForInteractionList: $bluetooth.characteristicsForInteraction, constrainToCompatiblePeripherals: true)
            }
        })
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(
                BluetoothModel(connectionSuccessFlag: .init(initialValue: false))
            )
            .statusBar(hidden: true)
    }
}
