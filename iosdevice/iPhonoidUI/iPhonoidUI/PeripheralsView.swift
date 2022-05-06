//  
//  PeripheralsView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.3
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct PeripheralsView: View {
    
    @EnvironmentObject var bluetooth: BluetoothModel
    
    var body: some View {
        NavigationView {
            Form{
                Section("PAIRED DEVICES"){
                    ForEach(Array(0...1), id:\.self){ item in
                        Button("Device \(item)"){
                            bluetooth.connectionSuccess = true
                            bluetooth.stopScanning()
                        }
                    }
                }
                Section("AVAILABLE DEVICES"){
                    ForEach(Array(bluetooth.discoveredPeripherals.values)){ peripheral in
                        Button {
                            bluetooth.connectTo(peripheral as PeripheralModel)
                        } label: {
                            HStack(){
                                Text("\(peripheral.name)")
                                Spacer()
                                Text("\(peripheral.rssi!)")
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Peripherals"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack) // Redundant statement that fixes constraints warnings in debug console
    }
}

struct PeripheralsView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralsView()
            .environmentObject(
                BluetoothModel(connectionSuccessFlag: .init(initialValue: false))
            )
            .statusBar(hidden: true)
            .previewLayout(.sizeThatFits)
    }
}
