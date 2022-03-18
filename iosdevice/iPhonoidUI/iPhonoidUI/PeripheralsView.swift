//  
//  PeripheralsView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
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
                            appState.btConnectionSuccessful = true
                        }
                    }
                }
                Section("AVAILABLE DEVICES"){
                    ForEach(Array(0...2), id:\.self){ item in
                        Button("Device \(item)"){
                            appState.btConnectionSuccessful = true
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
            .environmentObject(AppStateModel(
                btConnectionSuccess: .init(initialValue: false))
            )
            .statusBar(hidden: true)
            .previewLayout(.sizeThatFits)
    }
}
