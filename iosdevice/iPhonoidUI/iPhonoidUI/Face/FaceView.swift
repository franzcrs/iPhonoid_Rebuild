//
//  FaceView.swift
//  
//  View component for the iPhonoid Face screen. It arranges the facial elements
//  in a landscape orientation with a layout dependent on the device displays' width.
//  This version uses png files for the facial elements
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/08
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct FaceView: View {
    
    var displayConventional = DisplayConventionalDimensions()
    var orientationLock = OrientationLock()
    var body: some View {
        HStack (alignment: .center, spacing: 0) {
            Rectangle()
                .fill(.black)
                .frame(width: self.displayConventional.width() > 375 ? 40 : 20) // 40 pts will cover the notch for devices bigger than iphone 7, 8, SE
                .overlay(Text("\(Int(UIScreen.main.fixedCoordinateSpace.bounds.width))")
                            .foregroundColor(.white))
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 25)
                    .padding(6)
                    .foregroundColor(.white)
                VStack(alignment: .center, spacing: self.displayConventional.width() / 12) {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 1)
                    HStack(alignment: .top,
                           spacing: self.displayConventional.width() / 4.6) {
                        Image("eye1")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(nil, contentMode: .fit)
                        Image("eye1")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(nil, contentMode: .fit)
                    }.frame(height: .maximum(180, self.displayConventional.width() / 2))
                        .overlay(Text("\(Int(UIScreen.main.fixedCoordinateSpace.bounds.width/2))")
                                    .foregroundColor(.black))
                    Image("mouth1")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(nil, contentMode: .fit)
                        .frame(width: self.displayConventional.width() / 3)
                }.padding(6)
            }
            Rectangle()
                .fill(.black)
                .frame(width: self.displayConventional.width() > 375 ? 40 : 20)
        }
        .background(.black)
        .onAppear(perform:{
            self.orientationLock.lock(UIInterfaceOrientation.landscapeRight)
            }// Forcing rotation and locking the orientation to landscape right
        )
        .onDisappear(perform:{
            self.orientationLock.unlock()
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        FaceView()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice("iPhone 8 Plus")
    }
}
