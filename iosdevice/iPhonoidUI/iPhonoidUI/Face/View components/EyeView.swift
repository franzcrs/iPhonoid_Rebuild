//  
//  EyeView.swift
//  
//  Animatable and vectorial Eye view component definition. Remember to modify
//  the view with a .foregroundColor modifier to give the component a color, and
//  with a .environmentObject modifier passing an EyeModel instance.
//  The view component now has two initializers. First one computes the width
//  from the entered value of height. Second one let you initialize both values
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/05
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct MainShape: Shape{
    
//    @Binding var eyeClosed: Bool
    @EnvironmentObject var EyeStatus: EyeModel
    
    var horizControllersStretch: CGFloat {
        switch EyeStatus.state{
            case .open:
                return 0.38
            case .closed:
                return 0.75
            case .happy:
                return 0.75
        }
    }
    var vertControllersStretch: CGFloat {
        switch EyeStatus.state{
            case .open:
                return 0.8
            case .closed:
                return 0.1
            case .happy:
                return 0.1
        }
    }
    var upperPointDisplacement: CGFloat {
        switch EyeStatus.state{
            case .open:
                return 0
            case .closed:
                return 1.2
            case .happy:
                return 0.6
        }
    }
    var lowerPointDisplacement: CGFloat {
        switch EyeStatus.state{
            case .open:
                return 0
            case .closed:
                return 0.6
            case .happy:
                return 1.2
        }
    }
    
//    var horizControllersStretch: CGFloat {eyeClosed ? 0.75 : 0.38}
//    var vertControllersStretch: CGFloat {eyeClosed ? 0.1 : 0.8}
//    var upperPointDisplacement: CGFloat {eyeClosed ? 1.2 : 0}
//    var lowerPointDisplacement: CGFloat {eyeClosed ? 0.6 : 0}
    
//    var horizControllersStretch: CGFloat = 0.38
//    var vertControllersStretch: CGFloat = 0.8
//    var upperPointDisplacement: CGFloat = 0
//    var lowerPointDisplacement: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        Path {path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.midY * upperPointDisplacement),
                control1: CGPoint(x: rect.minX , y: rect.midY * (1 - vertControllersStretch)),
                control2: CGPoint(x: rect.midX * (1 - horizControllersStretch), y: rect.midY * upperPointDisplacement + horizControllersStretch))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY),
                control1: CGPoint(x: rect.midX * (1 + horizControllersStretch), y: rect.midY * upperPointDisplacement + horizControllersStretch),
                control2: CGPoint(x: rect.maxX, y: rect.midY * (1 - vertControllersStretch)))
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.midY * (2 - lowerPointDisplacement)),
                control1: CGPoint(x: rect.maxX, y: rect.midY * (1 + vertControllersStretch)),
                control2: CGPoint(x: rect.midX * (1 + horizControllersStretch), y: rect.midY * (2 - lowerPointDisplacement) - horizControllersStretch))
            path.addCurve(
                to: CGPoint(x: rect.minX, y: rect.midY),
                control1: CGPoint(x: rect.midX * (1 - horizControllersStretch), y: rect.midY * (2 - lowerPointDisplacement) - horizControllersStretch),
                control2: CGPoint(x: rect.minX, y: rect.midY * (1 + vertControllersStretch)))
        }
    }
}

struct EyeView: View {
    
    var width: CGFloat
    var height: CGFloat
//    @Binding var closed: Bool
    
//    init(height: CGFloat, closed: Binding<Bool>) {
    init(height: CGFloat) {
        self.width = height/3.5
        self.height = height
//        self._closed = closed
    }
    
//    init(width: CGFloat, height: CGFloat, closed: Binding<Bool>) {
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
//        self._closed = closed
    }
    
    var body: some View {
        ZStack(){
//            MainShape(eyeClosed: self.$closed)
            MainShape()
            Image("eyeGlow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: self.height / 4.6)
                .position(x: self.width / 2.6,
                          y: self.height / 4.8)
        }
        .frame(width: self.width, height: self.height)
//        .onTapGesture(perform: {self.closed.toggle()})
    }
}
    
struct EyeView_Previews: PreviewProvider {
    static var previews: some View {
//        EyeView(height: 280, closed: .constant(false))
        EyeView(height: 280)
            .environmentObject(EyeModel())
            .foregroundColor(.brown)
            .frame(width: 100, height: 320)
            .background(Color.white)
    }
}
