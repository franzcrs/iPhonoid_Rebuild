//
//  FaceView.swift
//  
//  View component for the iPhonoid Face screen. It arranges the facial elements
//  in a landscape orientation with a layout dependent on the device displays' width.
//  This version now has vectorial components as eyes and mouth, and one, two and
//  three tap gestures are handled to change the facial expression
//  
//  Version: 0.5
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/08
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct FaceView: View {
    
    private var displayConventional = DisplayConventionalDimensions()
    private var orientationLock = OrientationLock()
    @EnvironmentObject var faceViewData: FaceViewModel
    @EnvironmentObject var bluetooth: BluetoothModel
    
    var body: some View {
        HStack (alignment: .center, spacing: 0) {
            Rectangle()
                .fill(.black)
                .frame(width: self.displayConventional.width() > 375 ? 40 : 20) // 40 pts will cover the notch for devices bigger than iphone 7, 8, SE
//                .overlay(
//                    GeometryReader{proxy in
//                        Color.clear
//                            .overlay(Text("\(Int(proxy.size.width))\r\n" +
//                                          "\(Int(proxy.size.height))")
//                                        .foregroundColor(.white))
//                    })
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
                        EyeView(height: .maximum(180, self.displayConventional.width() / 2) - 18)
                            .environmentObject(faceViewData.rightEye)
                            .foregroundColor(Color(hex: 0x2A2F36))
                            .frame(width: (.maximum(180, self.displayConventional.width() / 2) / 1.25).rounded(),
                                   height: .maximum(180, self.displayConventional.width() / 2))
//                            .border(Color.blue, width: 2)
//                            .overlay(
//                                GeometryReader{proxy in
//                                    Color.clear
//                                        .overlay(Text("\(Int(proxy.size.width))\r\n" +
//                                                      "\(Int(proxy.size.height))")
//                                                    .foregroundColor(.white))
//                                })
//                            .gesture(SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
//                                        .onEnded { gestureValue in
//                                            if gestureValue.second != nil {
//                                                faceViewData.rightEye.updateState(to: .happy)
//                                            } else if gestureValue.first != nil {
//                                                faceViewData.rightEye.updateState(to: .open)
//                                            }
//                                        })
//                            .onTapGesture(perform: {
//                                faceViewData.rightEye.updateState(to: .closed)
//                            })
                        EyeView(height: .maximum(180, self.displayConventional.width() / 2) - 18)
                            .environmentObject(faceViewData.leftEye)
                            .foregroundColor(Color(hex: 0x2A2F36))
                            .frame(width: (.maximum(180, self.displayConventional.width() / 2) / 1.25).rounded(),
                                   height: .maximum(180, self.displayConventional.width() / 2))
//                            .overlay(
//                                GeometryReader{ proxy in
//                                    Color.clear
//                                        .overlay(Text("\(Int(proxy.size.width))\r\n" +
//                                                      "\(Int(proxy.size.height))")
//                                                    .foregroundColor(.white))
//                                })
//                            .gesture(SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
//                                        .onEnded { gestureValue in
//                                            if gestureValue.second != nil {
//                                                faceViewData.leftEye.updateState(to: .happy)
//                                            } else if gestureValue.first != nil {
//                                                faceViewData.leftEye.updateState(to: .open)
//                                            }
//                                        })
//                            .onTapGesture(perform: {
//                                faceViewData.leftEye.updateState(to: .closed)
//                            })
                    }
//                           .overlay(
//                               GeometryReader{ proxy in
//                                   Color.clear
//                                       .overlay(Text("\(Int(proxy.size.width)), " +
//                                                     "\(Int(proxy.size.height))")
//                                                   .foregroundColor(.black))
//                               })
//                    ZStack {
//                        Image("mouth1")
//                            .renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(nil, contentMode: .fit)
//                            .frame(width: (self.displayConventional.width() / 3).rounded(.down))
//                            .overlay(
//                                GeometryReader{ proxy in
//                                    Color.clear
//                                        .overlay(Text("\(Int(proxy.size.width)), " +
//                                                      "\(Int(proxy.size.height))")
//                                                    .foregroundColor(.black))
//                            })
                    MouthView(width: self.displayConventional.width() / 3.1)
                        .environmentObject(faceViewData.mouth)
//                        .border(Color.blue, width: 2)
//                    }
                }.padding(6)
            }
            .gesture(SimultaneousGesture(TapGesture(count: 2), TapGesture(count: 3))
                        .onEnded { gestureValue in
                if gestureValue.second != nil {
                    faceViewData.sleep()
                    bluetooth.sendCommand(of7chars: "irla002")
                } else if gestureValue.first != nil {
                    faceViewData.sad()
                    bluetooth.sendCommand(of7chars: "irla102")
                }
            })
            .onTapGesture(perform: {
                faceViewData.happy()
                bluetooth.sendCommand(of7chars: "brhz002")
            })
            Rectangle()
                .fill(.black)
                .frame(width: self.displayConventional.width() > 375 ? 40 : 20)
        }
        .background(.black)
        .onAppear(perform:{
            self.orientationLock.lock(UIInterfaceOrientation.landscapeRight) // Forcing rotation and locking the orientation to landscape right
            print(bluetooth.characteristicsForInteraction)
            print(bluetooth.connectedPeripheral)
            print(bluetooth.discoveredPeripherals)
            bluetooth.sendCommand(of7chars: "brra001")
        }
        )
        .onDisappear(perform:{
            self.orientationLock.unlock()
        })
        .onChange(of: bluetooth.characteristicsForInteraction) { _ in
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        FaceView()
            .environmentObject(FaceViewModel())
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice("iPhone 13 Pro Max")
    }
}
