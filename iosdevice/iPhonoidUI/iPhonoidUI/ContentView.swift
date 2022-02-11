//  
//  ContentView.swift
//  
//  Playground for testing ideas and portions of code
//  Later move code to a its proper single purpose View.swift file
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/01/27
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct ContentView: View {
    
    @Binding var eyeClosed: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white)
            EyeView(size: CGSize(width: 80, height: 280), closed: $eyeClosed)
                .foregroundColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(eyeClosed: .constant(true))
                .previewInterfaceOrientation(.landscapeRight)
                .previewDevice("iPhone 12 Pro")
        }
    }
}
