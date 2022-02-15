//
//  FaceView.swift
//  
//  View component for the iPhonoid Face screen. It arranges the facial elements
//  in a landscape orientation with a layout dependent on the device displays' width.
//  This version now has vectorial components as eyes.
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/08
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct FaceView: View {
    
    private var displayConventional = DisplayConventionalDimensions()
    private var orientationLock = OrientationLock()
//    @ObservedObject var faceViewData = FaceViewData()
    @EnvironmentObject var faceViewData: FaceViewData
    
    var body: some View {
        HStack (alignment: .center, spacing: 0) {
            Rectangle()
                .fill(.black)
                .frame(width: self.displayConventional.width() > 375 ? 40 : 20) // 40 pts will cover the notch for devices bigger than iphone 7, 8, SE
                .overlay(
                    GeometryReader{proxy in
                        Color.clear
                            .overlay(Text("\(Int(proxy.size.width))\r\n" +
                                          "\(Int(proxy.size.height))")
                                        .foregroundColor(.white))
                    })
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 25)
                    .padding(6)
                    .foregroundColor(.white)
                VStack(alignment: .center, spacing: self.displayConventional.width() / 12) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 1)
                    HStack(alignment: .center,
                           spacing: self.displayConventional.width() / 4.6) {
//                        Image("eye1")
//                            .renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(nil, contentMode: .fit)
                        EyeView(height: .maximum(180, self.displayConventional.width() / 2) - 18
//                                ,closed: $faceViewData.rightEyeClosed)
                        )
                            .environmentObject(faceViewData.rightEyeState)
                            .foregroundColor(.black)
                            .frame(width: (.maximum(180, self.displayConventional.width() / 2) / 1.25).rounded(),
                                   height: .maximum(180, self.displayConventional.width() / 2))
                            .overlay(
                                GeometryReader{proxy in
                                    Color.clear
                                        .overlay(Text("\(Int(proxy.size.width))\r\n" +
                                                      "\(Int(proxy.size.height))")
                                                    .foregroundColor(.white))
                                })
                            .gesture(SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
                                        .onEnded { gestureValue in
                                            if gestureValue.second != nil {
                                                faceViewData.rightEyeState.updateState(to: .happy)
                                            } else if gestureValue.first != nil {
                                                faceViewData.rightEyeState.updateState(to: .open)
                                            }
                                        })
                            .onTapGesture(perform: {
                                faceViewData.rightEyeState.updateState(to: .closed)
                            })
                        EyeView(height: .maximum(180, self.displayConventional.width() / 2) - 18
//                                ,closed: $faceViewData.leftEyeClosed)
                        )
                            .environmentObject(faceViewData.leftEyeState)
                            .foregroundColor(.black)
                            .frame(width: (.maximum(180, self.displayConventional.width() / 2) / 1.25).rounded(),
                                   height: .maximum(180, self.displayConventional.width() / 2))
                            .overlay(
                                GeometryReader{ proxy in
                                    Color.clear
                                        .overlay(Text("\(Int(proxy.size.width))\r\n" +
                                                      "\(Int(proxy.size.height))")
                                                    .foregroundColor(.white))
                                })
                            .gesture(SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
                                        .onEnded { gestureValue in
                                            if gestureValue.second != nil {
                                                faceViewData.leftEyeState.updateState(to: .happy)
                                            } else if gestureValue.first != nil {
                                                faceViewData.leftEyeState.updateState(to: .open)
                                            }
                                        })
                            .onTapGesture(perform: {
                                faceViewData.leftEyeState.updateState(to: .closed)
                            })
                    }
                           .frame(height: .maximum(180, self.displayConventional.width() / 2))
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
            .environmentObject(FaceViewData())
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice("iPhone 8 Plus")
    }
}
