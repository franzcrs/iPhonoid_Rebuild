//  
//  SettingsView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.3
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var appState: AppStateModel
    @EnvironmentObject var bluetooth: BluetoothModel
    
    var body: some View {
        NavigationView {
                Form {
                    Section("General information"){
                        HStack{
                            Text("Device name")
                            Spacer()
                            Text("TODO")
                        }
                        HStack{
                            Text("App version")
                            Spacer()
                            Text("TODO")
                        }
                    }
                    Section("Bluetooth Status"){
                        NavigationLink(destination: PeripheralsView()){
                            if (bluetooth.connectionSuccess){
                                HStack{
                                    Text("Connected to")
                                    Spacer()
//                                    Text(appState.bluetoothConnectivity?.connectedPeripheral?.name ?? "Falied to retrieve name")
                                }
                            }
                            else {
                                HStack{
                                    Text("Connect to a peripheral")
                                }
                                
                            }
                        }
                        if (bluetooth.connectionSuccess){
                            HStack{
                                Text("RSSI")
                                Spacer()
//                                Text("\(appState.bluetoothConnectivity?.connectedPeripheral?.rssi ?? NSNumber(integerLiteral: 0101010101)) dB")
                            }
                        }
                    }
                    ForEach(Array(0...1), id:\.self){ _ in
                        Section("Group"){
                            Text("Element")
                        }
                    }
                }
                .navigationTitle(Text("Settings"))
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack) // Redundant statement that fixes constraints warnings in debug console
//        .navigationViewStyle(.automatic)
        .onChange(of: bluetooth.connectionSuccess) { _ in
            if bluetooth.connectionSuccess {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(
//                AppStateModel(bodyConnectionInitialState: .init(initialValue: false))
                BluetoothModel(connectionSuccessFlag: .init(initialValue: false))
            )
            .statusBar(hidden: true)
            .previewLayout(.sizeThatFits)
    }
}
