//  
//  SettingsView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppStateModel
    
    var body: some View {
        NavigationView {
                Form {
                    Section(){
                            Text("Bluetooth status:")
                            Text("Device name:")
                    }
                    Section(){
                        NavigationLink(destination: PeripheralsView()){
                            Text("Connect to a peripheral")
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
        .onChange(of: appState.btConnectionSuccessful) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppStateModel(
                btConnectionSuccess: .init(initialValue: false))
            )
            .statusBar(hidden: true)
            .previewLayout(.sizeThatFits)
    }
}
