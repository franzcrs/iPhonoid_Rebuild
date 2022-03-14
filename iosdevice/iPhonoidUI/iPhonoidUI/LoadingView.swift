//  
//  LoadingView.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/06
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

//extension UIViewController {
//    func add(_ child: UIViewController) {
//        self.addChild(child)
//        self.view.addSubview(child.view)
//        child.didMove(toParent: self)
//    }
//
//    func remove() {
//        guard self.parent != nil else {
//            return
//        }
//        self.willMove(toParent: nil)
//        self.removeFromParent()
//        self.view.removeFromSuperview()
//    }
//}

extension View{
    
    func presentModallyAs(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        
        if isPresented.wrappedValue{
            // Obtaining the ViewController of the current Window
            let windowScene:UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            // As there will only be one instance of the app we can choose the first
            // In case there are more than one, use the filter method .filter({$0.activationState == .foregroundActive})
            // before selecting the first
//            var topViewController = windowScene.windows.filter({$0.isKeyWindow}).first?.rootViewController
            // Apparently the windows array orders the windows from back to front by window level;
            // thus, the last window in the array is on top of all other app windows.
            // Refer to: https://developer.apple.com/documentation/uikit/uiapplication/1623104-windows
//            var topViewController = windowScene.windows.last?.rootViewController
            var topViewController:UIViewController? = windowScene.keyWindow?.rootViewController
            while let newTopViewController = topViewController!.presentedViewController{
                topViewController = newTopViewController
            }
            let viewControllerFromView = UIHostingController(rootView: self)
            topViewController!.modalPresentationCapturesStatusBarAppearance = true
//            print(viewControllerFromView.prefersStatusBarHidden)
            viewControllerFromView.providesPresentationContextTransitionStyle = true
            viewControllerFromView.definesPresentationContext = true
            viewControllerFromView.modalPresentationStyle = modalPresentationStyle
            viewControllerFromView.modalTransitionStyle = modalTransitionStyle
            // TODO: Specify constraints
//            viewControllerFromView.view.translatesAutoresizingMaskIntoConstraints = false
//            let constraints = [
//                viewControllerFromView.view.topAnchor.constraint(equalTo: topViewController!.view.topAnchor),
//                viewControllerFromView.view.leftAnchor.constraint(equalTo: topViewController!.view.leftAnchor),
//                topViewController!.view.bottomAnchor.constraint(equalTo: viewControllerFromView.view.bottomAnchor),
//                topViewController!.view.rightAnchor.constraint(equalTo: viewControllerFromView.view.rightAnchor)
//            ]
//            NSLayoutConstraint.activate(constraints)
            topViewController!.present(viewControllerFromView, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isPresented.wrappedValue = false
            }
        }
        return EmptyView()
    }
    /*
    func presentScreenAs<Content>(_ modalPresentationStyle: UIModalPresentationStyle, when isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, content: @escaping () -> Content) -> some View where Content: View {
        
        if isPresented.wrappedValue{
            // Obtaining the ViewController of the current Window
            
            let windowScene:UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            // As there will only be one instance of the app we can choose the first
            // In case there are more than one, use the filter method .filter({$0.activationState == .foregroundActive})
            // before selecting the first
            
//            var topViewController = windowScene.windows.filter({$0.isKeyWindow}).first?.rootViewController
            // Apparently the windows array orders the windows from back to front by window level;
            // thus, the last window in the array is on top of all other app windows.
            // Refer to: https://developer.apple.com/documentation/uikit/uiapplication/1623104-windows
//            var topViewController = windowScene.windows.last?.rootViewController
            var topViewController:UIViewController? = windowScene.keyWindow?.rootViewController
            while let newTopViewController = topViewController!.presentedViewController{
                topViewController = newTopViewController
            }
            let viewControllerFromView = UIHostingController(rootView: content())
            viewControllerFromView.providesPresentationContextTransitionStyle = true
            viewControllerFromView.definesPresentationContext = true
            viewControllerFromView.modalPresentationStyle = modalPresentationStyle
            viewControllerFromView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//            topViewController!.add(viewControllerFromView)
//            topViewController!.showDetailViewController(viewControllerFromView, sender: self)
            topViewController!.present(viewControllerFromView, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isPresented.wrappedValue = false
            }
        }
        return self
    }
     */
}

struct LoadingView: View {
    
    @EnvironmentObject var appState: AppStateModel
    @State private var showSettings: Bool = false
    
    var body: some View {
        Group {
            Text("Loading . . .")
                .font(.title).bold()
                .onAppear(perform: {
                    if !appState.btConnectionSuccessful {
                        showSettings.toggle()
                    }
                })
            SettingsView()
                .interactiveDismissDisabled()
                .modifier(ForNewRootView(AppStateInstance: appState))
                .presentModallyAs(.formSheet, withTransition: .coverVertical, when: $showSettings)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(AppStateModel(
                btConnectionSuccess: .init(initialValue: false))
            )
            .statusBar(hidden: true)
    }
}
