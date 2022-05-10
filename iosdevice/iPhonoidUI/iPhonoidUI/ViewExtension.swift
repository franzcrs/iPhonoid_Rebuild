//  
//  ViewExtension.swift
//  
//  *Describe purpose*
//  
//  Version: 0.1
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/04/12
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

extension View {
    
    /*
     Use of a View Modifier structure to present modals inspired by author of:
     https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
     */
    func presentModallyAs<Content>(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content, onDismiss: @escaping (() -> Void) = {}) -> some View where Content : View {
        self.modifier(PresentModallyAsModifier(modalPresentationStyle: modalPresentationStyle, modalTransitionStyle: modalTransitionStyle, isPresented: isPresented, modalContent: content, onDismiss: onDismiss))
    }
    
    func getCurrentlyPresentedVC() -> UIViewController {
        let windowScene:UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        var currentlyPresentedVC:UIViewController = (windowScene.keyWindow?.rootViewController)!
        while let lastPresentedVC = currentlyPresentedVC.presentedViewController {
            if lastPresentedVC.isModalInPresentation {
                break
            }
            currentlyPresentedVC = lastPresentedVC
        }
        currentlyPresentedVC.modalPresentationCapturesStatusBarAppearance = true
        return currentlyPresentedVC
    }
    
    func presentModallyAs(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, onDismiss: @escaping (() -> Void) = {}) -> some View {
        if modalTransitionStyle == .partialCurl{
            print("Error: presentModallyAs does not support UIModalTransitionStyle.partialCurl because behaviour of that transition style is unexpected")
        }
        else if isPresented.wrappedValue{
            let sourceVC = self.getCurrentlyPresentedVC()
            let viewControllerFromView = ModalPresentationHostingController(isPresented: isPresented, onDismiss: onDismiss, rootView: self)
            viewControllerFromView.modalPresentationStyle = modalPresentationStyle
            viewControllerFromView.modalTransitionStyle = modalTransitionStyle
            if let popover = viewControllerFromView.popoverPresentationController {
                print("Error: You are not using the correct order declaration of functions to show a popover. \nPresenting an automatic adaptation")
                let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                popover.sourceView = uiView
                popover.sourceRect = uiView.bounds
            }
            if let presentedVC = sourceVC.presentedViewController {
                presentedVC.dismiss(animated: true) {
                        sourceVC.present(viewControllerFromView, animated: true, completion: nil)
                }
            } else {
                    sourceVC.present(viewControllerFromView, animated: true, completion: nil)
            }
        }
        return EmptyView()
    }
    
    func presentModallyAsA<Closure>(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, onDismiss: (() -> Void) = {}, appearingFrom anchorViewFrame: Binding<CGRect> = Binding.constant(CGRect()), content closure: @escaping () -> Closure) -> some View where Closure: View{
        if modalTransitionStyle == .partialCurl{
            print("Error: presentModallyAs does not support UIModalTransitionStyle.partialCurl because behaviour of that transition style is unexpected")
        }
        else if isPresented.wrappedValue{
            let topViewController = getCurrentlyPresentedVC()
            var modalViewControllerFromView = ModalPresentationViewController(presentView: closure, as: modalPresentationStyle, withTransition: modalTransitionStyle)
            if anchorViewFrame.wrappedValue != CGRect() {
                modalViewControllerFromView = ModalPresentationViewController(presentView: closure, as: modalPresentationStyle, withTransition: modalTransitionStyle, fromPresentingView: topViewController.view, appearingFrom: anchorViewFrame)
            }
            topViewController.present(modalViewControllerFromView, animated: false, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                print("written false")
                isPresented.wrappedValue = false
            }
        }
        return self
    }
}

class CustomHostingController<Content>: UIHostingController<Content> where Content:View {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.35, animations: {
            self.presentingViewController?.view.backgroundColor = .black.withAlphaComponent(0.0)
        })
        print("in viewWillDisappear")
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            //        let currentViewController = EmptyView().getCurrentlyPresentedViewController() as? ModalPresentationViewController<Content>
        let currentViewController = EmptyView().getCurrentlyPresentedVC()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
            currentViewController.dismiss(animated: false, completion: nil)
        }
        print("in viewDidDisappear")
    }
}

class ModalPresentationViewController<Content>: UIViewController, UIPopoverPresentationControllerDelegate where Content: View{
    
    var viewControllerFromView: CustomHostingController<Content>?
    private var anchorViewFrame: Binding<CGRect>?
//    private var presentingView: UIView?
    private var orientationOptions: [UIInterfaceOrientationMask]?
    private var anchorViewFrameCollection: [UInt:CGRect]?
    private var isResuming: Bool = false
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(presentView: () -> Content, as modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle){
        super.init(nibName: nil, bundle: nil)
        viewControllerFromView = CustomHostingController(rootView: presentView())
        viewControllerFromView!.modalPresentationStyle = modalPresentationStyle
        viewControllerFromView!.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = .overFullScreen
    }
    
    convenience init(presentView: () -> Content, as modalPresentationStyle: UIModalPresentationStyle = .popover, withTransition modalTransitionStyle: UIModalTransitionStyle, fromPresentingView presentingView: UIView, appearingFrom anchorViewFrame: Binding<CGRect>){
        self.init(presentView: presentView, as: modalPresentationStyle, withTransition: modalTransitionStyle)
        self.anchorViewFrame = anchorViewFrame
//        self.presentingView = presentingView
        self.orientationOptions = [.landscape, .portrait]
        self.anchorViewFrameCollection = [:]
        if let viewPopoverPresentationController = viewControllerFromView!.popoverPresentationController {
            viewControllerFromView!.preferredContentSize = CGSize(width: UIScreen.main.fixedCoordinateSpace.bounds.height*0.3, height: UIScreen.main.fixedCoordinateSpace.bounds.height*0.5)
            print(viewControllerFromView!.preferredContentSize)
//            viewPopoverPresentationController.configureAnchorPoint(presentingView: self.presentingView!, anchorViewFrame: self.anchorViewFrame!.wrappedValue)
            viewPopoverPresentationController.delegate = self
            viewPopoverPresentationController.sourceView = presentingView
            viewPopoverPresentationController.sourceRect = self.anchorViewFrame!.wrappedValue
        }
    }
    
    /**
     UIViewController: Managing the View
     */
    override func loadView() {
        super.loadView()
        self.view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size))
        self.view.backgroundColor = .black.withAlphaComponent(0.0)
    }
    
    /**
     UIViewController: Responding to View-Related Events
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (isResuming == false) {
            self.view.backgroundColor = .black.withAlphaComponent(0.6)
            present(viewControllerFromView!, animated: true, completion: nil)
            isResuming = true
        }
    }
    
    /**
     UIViewController: View’s Layout Behavior
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Use this method to print after every rotation
//        self.popoverPresentationController!.sourceRect = self.anchorViewFrame!.wrappedValue // Assingment is after the rendering, so does not work here
    }
    
    /**
     UIContentContainer: Responding to Environment Changes
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let viewPopoverPresentationController = viewControllerFromView!.popoverPresentationController {
//        if (anchorViewFrame != nil){ // Do the following if instance was initialized for Popover
            let targetOrientationKey: UInt = self.orientationOptions![(size.height > size.width) ? Int(1) : Int(0)].rawValue
            let oppositeKey: UInt = self.orientationOptions![!(size.height > size.width) ? Int(1) : Int(0)].rawValue
            if anchorViewFrameCollection!.isEmpty{ // Running an async function for first rotation
//                presentedViewController!.dismiss(animated: true, completion: nil) // There was no need to dismiss and then present
                anchorViewFrameCollection![oppositeKey] = anchorViewFrame!.wrappedValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    viewPopoverPresentationController.sourceRect = self.anchorViewFrame!.wrappedValue
//                    self.viewControllerFromView!.popoverPresentationController?.configureAnchorPoint(presentingView: self.presentingView!, anchorViewFrame: self.anchorViewFrame!.wrappedValue)
//                    self.present(self.viewControllerFromView!, animated: true, completion: nil)
                }
            }
            else { // From the second rotation calls the values inside collection
                anchorViewFrameCollection![oppositeKey] = anchorViewFrame!.wrappedValue
                viewPopoverPresentationController.sourceRect = anchorViewFrameCollection![targetOrientationKey]!
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
