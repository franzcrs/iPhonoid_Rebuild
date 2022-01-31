//  
//  ContentView.swift
//  
//  Playground for testing ideas and portions of code
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack (alignment: .center, spacing: 0) {
            Rectangle()
                .fill(Color.black)
                .frame(width: 40) // 40 pts will adapt to the device and cover the notch
            RoundedRectangle(cornerRadius: 25)
                .padding(6)
                .foregroundColor(Color.white)
                .overlay(Text("'-' ._____. '-'")
                            .foregroundColor(Color.black))
            Rectangle()
                .fill(Color.black)
                .frame(width: 40)
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear(perform: {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation") // Forcing the rotation to landscape right
            AppDelegate.orientationLock = .landscapeRight // Locking the oritentation to landscape right
        })
        .onDisappear(perform:{
            AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
            
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewInterfaceOrientation(.landscapeRight)
                .previewDevice("iPhone 13 Pro")
        }
    }
}
