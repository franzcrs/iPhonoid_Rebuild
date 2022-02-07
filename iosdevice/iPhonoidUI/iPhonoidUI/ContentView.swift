//  
//  ContentView.swift
//  
//  Playground for testing ideas and portions of code
//  Later move code to a its proper single purpose View.swift file
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct displayStandardDimensions {
    func width() -> CGFloat {
        return UIScreen.main.fixedCoordinateSpace.bounds.width
    }
    func height() -> CGFloat {
        return UIScreen.main.fixedCoordinateSpace.bounds.height
    }
}

struct ContentView: View {
    
    var displayStandard = displayStandardDimensions()
    
    var body: some View {
        HStack (alignment: .center, spacing: 0) {
            Rectangle()
                .fill(Color.black)
                .frame(width: self.displayStandard.width() > 375 ? 40 : 20) // 40 pts will cover the notch for devices bigger than iphone 7, 8, SE
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 25)
                    .padding(6)
                    .foregroundColor(Color.white)
//                    .overlay(Text("'-' ._____. '-'")
//                            .foregroundColor(Color.black))
                VStack(alignment: .center, spacing: self.displayStandard.width() / 12) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                    HStack(alignment: .top,
                           spacing: self.displayStandard.width() / 4.6) {
                        Image("eye1")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Image("eye1")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }.frame(height: .maximum(180, self.displayStandard.width() / 2))
                    Image("mouth1")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: self.displayStandard.width() / 3)
                }.padding(6)
            }
            Rectangle()
                .fill(Color.black)
                .frame(width: self.displayStandard.width() > 375 ? 40 : 20)
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
                .previewDevice("iPhone 12 Pro")
        }
    }
}
