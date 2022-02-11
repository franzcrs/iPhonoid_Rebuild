//  
//  EyeView.swift
//  
//  Animatable and vectorial Eye view component definition. Remember to modify
//  the view with a .foregroundColor modifier to give the component a color
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/05
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct MainShape: Shape{
    
    @Binding var eyeClosed: Bool
    
    var horizControllersStretch: CGFloat {eyeClosed ? 0.75 : 0.38}
    var vertControllersStretch: CGFloat {eyeClosed ? 0.1 : 0.8}
    var upperPointDisplacement: CGFloat {eyeClosed ? 1.2 : 0}
    var lowerPointDisplacement: CGFloat {eyeClosed ? 0.6 : 0}
    
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
    
//    func toggleState() -> Void {
//        withAnimation(.default){
//            eyeClosed.toggle()
//        }
//    }
//
//    func blinkAnimation(delay: Double) -> Void {
//        withAnimation(.default){
//            eyeClosed.toggle()
//        }
//        withAnimation(.default.delay(delay)){
//            eyeClosed.toggle()
//        }
//    }
}

//struct EyeComposition: View {
//
//    var size: CGSize
//
//    var body: some View{
//        ZStack(){
////            MainShape()
////                .foregroundColor(Color.white)
//            MainShapeC()
//            Image("eyeGlow")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: self.size.height / 4.6)
//                .position(x: self.size.width / 2.6, y: self.size.height / 4.8)
//
//        }
//    }
//}

struct EyeView: View {
    
    var size: CGSize
    @Binding var closed: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack(){
                MainShape(eyeClosed: $closed)
                Image("eyeGlow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: self.size.height / 4.6)
                    .position(x: self.size.width / 2.6,
                              y: self.size.height / 4.8)
            }
            .frame(width: self.size.width, height: self.size.height)
            Button("Toggle"){
                closed.toggle()
            }
        }
    }
    
    
}

struct EyeView_Previews: PreviewProvider {
    static var previews: some View {
        EyeView(size: CGSize(width: 80, height: 280), closed: .constant(false))
            .foregroundColor(.brown)
            .frame(width: 100, height: 320)
            .background(Color.white)
    }
}
