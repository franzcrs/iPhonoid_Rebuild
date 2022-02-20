//  
//  EyeView.swift
//  
//  Animatable and vectorial Eye view component definition. Remember to modify
//  the view with a .foregroundColor modifier to give the component a color, and
//  with a .environmentObject modifier passing an EyeModel instance.
//  The view component now has two initializers. First one computes the width
//  from the entered value of height. Second one let you initialize both values
//  
//  Version: 0.3
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/05
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct MainShape: Shape{
    
    @EnvironmentObject var Eye: EyeModel
    
    // Coordinates modifiers
    var halfWidthEtensionFactor: CGFloat {
        switch Eye.state{
            case .closed:
                return 0.75
            case .happy:
                return 0.75
            default:
                return 0.38
        }
    }
    var halfHeightExtensionFactor: CGFloat {
        switch Eye.state{
            case .closed:
                return 0.1
            case .happy:
                return 0.1
            default:
                return 0.8
        }
    }
    var topYInwardsOffset: CGFloat {
        switch Eye.state{
            case .open:
                return 0
            case .closed:
                return 1.2
            case .happy:
                return 0.6
            case .angry:
                return 0.3
            case .sad:
                return 0.32
        }
    }
    var bottomYInwardsOffset: CGFloat {
        switch Eye.state{
            case .closed:
                return 0.6
            case .happy:
                return 1.2
            default:
                return 0
        }
    }
    var upperSlope: CGFloat{
        switch Eye.state {
            case .angry:
                return (Eye.side == .left ? 1: (-1)) * 0.6
            case .sad:
                return (Eye.side == .left ? 1: (-1)) * -0.6
            default:
                return 0
        }
    }
    var topXExtensionFactor: CGFloat{
        switch Eye.state {
            case .angry:
                return 0.6
            case .sad:
                return 0.4
            default:
                return 0
        }
    }
    
    func path(in rect: CGRect) -> Path {
        // Coordinates calculations
        let vertTangentCtrlPoint_RelY = rect.midY * halfHeightExtensionFactor
        let vertTangentUpperCtrlPoint_DeltaY = rect.midX * upperSlope
        
        let upperPoint_AbsY = rect.midY * topYInwardsOffset
        let lowerPoint_AbsY = rect.midY * (2 - bottomYInwardsOffset)
        
        let horizTangentCtrlPoint_RelX = rect.midX * halfWidthEtensionFactor
        let horizTangentUpperCtrlPoint_AsymX = rect.midX * topXExtensionFactor
        let horizTangentUpperCtrlPoint_DeltaY = horizTangentUpperCtrlPoint_AsymX * upperSlope
        
        // Points definition
        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        let ctrlPoint_1 = CGPoint(x: rect.minX,
                                  y: Eye.state.ctrlPointsSymmetry
                                  ? rect.midY - vertTangentCtrlPoint_RelY
                                  : upperPoint_AbsY + vertTangentUpperCtrlPoint_DeltaY)
        let ctrlPoint_2 = CGPoint(x: Eye.state.ctrlPointsSymmetry
                                  ? rect.midX - horizTangentCtrlPoint_RelX
                                  : rect.midX - horizTangentUpperCtrlPoint_AsymX,
                                  y: Eye.state.ctrlPointsSymmetry
                                  ? upperPoint_AbsY
                                  : upperPoint_AbsY + horizTangentUpperCtrlPoint_DeltaY)
        let topPoint = CGPoint(x: rect.midX, y: upperPoint_AbsY)
        let ctrlPoint_3 = CGPoint(x: Eye.state.ctrlPointsSymmetry
                                  ? rect.midX + horizTangentCtrlPoint_RelX
                                  : rect.midX + horizTangentUpperCtrlPoint_AsymX,
                                  y: Eye.state.ctrlPointsSymmetry
                                  ? upperPoint_AbsY
                                  : upperPoint_AbsY - horizTangentUpperCtrlPoint_DeltaY)
        let ctrlPoint_4 = CGPoint(x: rect.maxX,
                                  y: Eye.state.ctrlPointsSymmetry
                                  ? rect.midY - vertTangentCtrlPoint_RelY
                                  : upperPoint_AbsY - vertTangentUpperCtrlPoint_DeltaY)
        let rightPoint = CGPoint(x: rect.maxX, y: rect.midY)
        let ctrlPoint_5 = CGPoint(x: rect.maxX, y: rect.midY + vertTangentCtrlPoint_RelY)
        let ctrlPoint_6 = CGPoint(x: rect.midX + horizTangentCtrlPoint_RelX, y: lowerPoint_AbsY)
        let bottomPoint = CGPoint(x: rect.midX, y: ctrlPoint_6.y)
        let ctrlPoint_7 = CGPoint(x: rect.midX - horizTangentCtrlPoint_RelX, y: ctrlPoint_6.y)
        let ctrlPoint_8 = CGPoint(x: rect.minX, y: ctrlPoint_5.y)
        
        return Path {path in
            path.move(to: startPoint)
            path.addCurve(to: topPoint, control1: ctrlPoint_1, control2: ctrlPoint_2)
            path.addCurve(to: rightPoint, control1: ctrlPoint_3, control2: ctrlPoint_4)
            path.addCurve(to: bottomPoint, control1: ctrlPoint_5, control2: ctrlPoint_6)
            path.addCurve(to: startPoint, control1: ctrlPoint_7, control2: ctrlPoint_8)
        }
    }
}

struct EyeView: View {
    
    var width: CGFloat
    var height: CGFloat
    
    init(height: CGFloat) {
        self.width = height/3.5
        self.height = height
    }
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ZStack(){
            MainShape()
            Image("eyeGlow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: self.height / 4.6)
                .position(x: self.width / 2.6,
                          y: self.height / 4.8)
        }
        .frame(width: self.width, height: self.height)
    }
}
    
struct EyeView_Previews: PreviewProvider {
    static var previews: some View {
        EyeView(height: 280)
            .environmentObject(EyeModel(side: .right, state: .init(initialValue: .sad)))
            .foregroundColor(.brown)
            .frame(width: 100, height: 320)
            .background(Color.white)
    }
}
