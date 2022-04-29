//  
//  PeripheralsView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct PeripheralsView: View {
    
//    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppStateModel
    
    var body: some View {
        NavigationView {
            Form{
                Section("PAIRED DEVICES"){
                    ForEach(Array(0...1), id:\.self){ item in
                        Button("Device \(item)"){
                            appState.bodyConnected = true
                        }
                    }
                }
                Section("AVAILABLE DEVICES"){
                    
//                    List (self.store.state.peripheralsList, id: \.self) { itemId in
//                        NavigationLink(destination: PeripheralView(peripheralId: itemId)) {
//                            Text("\(self.store.state.peripherals[itemId]!.name) (\(self.store.state.peripherals[itemId]!.rssi)dB)")
//                        }
//                    }
                    
                    ForEach(appState.bluetoothConnectivity?.discoveredPeripherals.keys.sorted() ?? [], id:\.self){ id in
                        Button("\((appState.bluetoothConnectivity?.discoveredPeripherals[id]!.name)!)"){
                            appState.bodyConnected = true
                        }
                    }
                    
//                    ForEach((appState.bluetoothConnectivity!.managerDelegate as! ManagerDelegateModel).discoveredPeripherals.keys.sorted(), id:\.self){ id in
//                        Button("\((appState.bluetoothConnectivity!.managerDelegate as! ManagerDelegateModel).discoveredPeripherals[id]!.name)"){
//                            appState.bodyConnected = true
//                        }
//                    }
                    
                    
//                    appState.bluetoothConnectivity?.discoveredPeripherals.forEach{ id, device in
//                        Button("\(device.cbPeripheral.name)"){
//                            appState.bodyConnected = true
//                        }
//                    }
//                    ForEach(Array(0...2), id:\.self){ item in
//                        Button("Device \(item)"){
//                            appState.bodyConnected = true
//                        }
//                    }
                }
            }
            .navigationTitle(Text("Peripherals"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack) // Redundant statement that fixes constraints warnings in debug console
        .onAppear(perform: {
            print("available")
            print(appState.bluetoothConnectivity!.discoveredPeripherals)
//                    print((appState.bluetoothConnectivity!.managerDelegate as! ManagerDelegateModel).discoveredPeripherals)
        })
//        .navigationViewStyle(.automatic)
    }
}

struct PeripheralsView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralsView()
            .environmentObject(AppStateModel(
                bodyConnectionInitialState: .init(initialValue: false))
            )
            .statusBar(hidden: true)
            .previewLayout(.sizeThatFits)
    }
}
