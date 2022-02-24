//  
//  MouthView.swift
//  
//  Animatable and vectorial Mouth view component definition. The initializer
//  requires to insert a width and computes the height from the entered value
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/02/20
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct MouthShape: Shape{
    
    @EnvironmentObject var mouth: MouthModel
    private var onlyStrokes: Bool
    private var strokeStyle: StrokeStyle?

    init() {
        self.onlyStrokes = false
    }
    
    init(onlyStrokes: Bool, _ strokeStyle: StrokeStyle) {
        self.onlyStrokes = onlyStrokes
        self.strokeStyle = strokeStyle
    }
    
    // Coordinates modifiers
    var halfWidthEtensionFactor: CGFloat {
        switch mouth.state{
            case .smiling:
                return 0.3
            case .happy:
                return 0.72
            case .sad:
                return 0.3
            case .angry:
                return 0.2
            case .surprised:
                return 0.3
        }
    }
    var topYAbsoluteOffset: CGFloat {
        switch mouth.state{
            case .smiling:
                return 1.3 //1.1 is more neutral. TODO: later implement intensity
            case .happy:
                return 0.25
            case .sad:
                return 0.7
            case .angry:
                return 0.7
            case .surprised:
                return 0.7
        }
    }
    var sidesXInwardsOffset: CGFloat {
        switch mouth.state{
            case .smiling:
                return 0.6
            case .happy:
                return 0
            case .sad:
                return 0.6
            case .angry:
                return 0.6
            case .surprised:
                return 0.6
        }
    }
    var sidesYAbsoluteOffset: CGFloat {
        switch mouth.state{
            case .smiling:
                return 1
            case .happy:
                return 0.25
            case .sad:
                return 1
            case .angry:
                return 1.3
            case .surprised:
                return 1
        }
    }
    var bottomYAbsoluteOffset: CGFloat {
        switch mouth.state{
            case .smiling:
                return topYAbsoluteOffset
            case .happy:
                return 1.82
            case .sad:
                return topYAbsoluteOffset
            case .angry:
                return topYAbsoluteOffset
            case .surprised:
                return 1.1
        }
    }
    
    func path(in rect: CGRect) -> Path {
        
        // Points definition
        let startPoint = CGPoint(x: rect.midX * sidesXInwardsOffset,
                                 y: rect.midY * sidesYAbsoluteOffset)
        let topPoint = CGPoint(x: rect.midX, y: rect.midY * topYAbsoluteOffset)
        let rightPoint = CGPoint(x: rect.midX * (2 - sidesXInwardsOffset),
                                 y: rect.midY * sidesYAbsoluteOffset)
        let bottomPoint = CGPoint(x: rect.midX,
                                  y: rect.midY * bottomYAbsoluteOffset)
        let ctrlPoint_1 = startPoint
        let ctrlPoint_2 = CGPoint(x: rect.midX * (1 - halfWidthEtensionFactor), y:topPoint.y)
        let ctrlPoint_3 = CGPoint(x: rect.midX * (1 + halfWidthEtensionFactor), y:topPoint.y)
        let ctrlPoint_4 = rightPoint
        let ctrlPoint_5 = rightPoint
        let ctrlPoint_6 = CGPoint(x: ctrlPoint_3.x, y: bottomPoint.y)
        let ctrlPoint_7 = CGPoint(x: ctrlPoint_2.x, y: bottomPoint.y)
        let ctrlPoint_8 = startPoint
        
        // Path creation
        var path = Path()
        path.move(to: startPoint)
        path.addCurve(to: topPoint, control1: ctrlPoint_1, control2: ctrlPoint_2)
        path.addCurve(to: rightPoint, control1: ctrlPoint_3, control2: ctrlPoint_4)
        path.addCurve(to: bottomPoint, control1: ctrlPoint_5, control2: ctrlPoint_6)
        path.addCurve(to: startPoint, control1: ctrlPoint_7, control2: ctrlPoint_8)
        
        if onlyStrokes {
                // Path method that returns Path type that transform the path into strokes.
                // Stroke conversion implemented inside Shape since modifying a View with .stroke
                // results in fatal error. It seems that it creates a new View to which
                // no environmentObject is passed
            path = path.strokedPath(strokeStyle!)
        }
        
        return path
    }
}

struct MouthView: View {
    
    var width: CGFloat
    
    init(width: CGFloat) {
        self.width = width
    }
    
    var body: some View {
        MouthShape()
            .foregroundColor(Color(hex:0xFFC9C7)) // fill y stroke cannot be used since they create a new View to which no environmentObject is passed
            .frame(width: width, height: width / 3.16)
            .overlay(
                MouthShape(onlyStrokes: true,
                           StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(hex: 0x2A2F36))
            )
    }
}

struct MouthView_Previews: PreviewProvider {
    static var previews: some View {
        MouthView(width: UIScreen.main.bounds.width)
            .environmentObject(MouthModel(state: .init(initialValue: .surprised)))
//            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 3.16)
    }
}
