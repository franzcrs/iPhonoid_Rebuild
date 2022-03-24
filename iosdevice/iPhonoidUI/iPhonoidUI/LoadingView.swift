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

extension UIPopoverPresentationController {
    func saveDelegate() {
        assert(self.delegate != nil)
    }
    func configureAnchorPoint(presentingView: UIView, anchorViewFrame: CGRect) -> Void {
        self.sourceView = presentingView
        self.sourceRect = anchorViewFrame
    }
}

class PopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
    @Binding var anchorViewFrame: CGRect

    init(_ anchorViewFrame: Binding<CGRect>){
        self._anchorViewFrame = anchorViewFrame
        print("Init delegate: \(_anchorViewFrame.wrappedValue)")
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        print("Inside prepareForPopoverPresentation: ")
    }
    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        print("Inside willPresentWithAdaptiveStyle: ")
    }
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
//        rect.pointee = CGRect(origin: $anchorViewFrame.origin.wrappedValue, size: $anchorViewFrame.size.wrappedValue)
        print("Inside willRepositionPopoverTo: \(rect.pointee)")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        print("AdaptivePresentationStyle")
        return .none
    }
}

class PopoverHostingController<Content>: UIHostingController<Content> where Content:View {
    @Binding var anchorViewFrame: CGRect
    private let orientation: [UIInterfaceOrientationMask] = [.landscape, .portrait]
    private var anchorViewFrameCollection: [UInt:CGRect] = [:]
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    init(anchorViewFrame: Binding<CGRect>, rootView: Content) {
        self._anchorViewFrame = anchorViewFrame
        super.init(rootView: rootView)
    }

    /**
     UIViewController: Managing the View
     */
    override func loadView() {
        super.loadView()
//        self.presentingViewController!.view.alpha = 0.3
        let popoverDelegate = PopoverDelegate($anchorViewFrame)
        withExtendedLifetime(popoverDelegate){
            self.popoverPresentationController!.delegate = popoverDelegate // Assignment doesn't work
            self.popoverPresentationController!.saveDelegate()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentingViewController!.view.alpha = 0.3
    }

    /**
     UIViewController: Responding to View-Related Events
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presentingViewController!.view.alpha = 1
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    /**
     UIViewController: View’s Layout Behavior
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("WillLayout: \(self.anchorViewFrame.debugDescription) \(String(describing: self.popoverPresentationController!.delegate))")
//        self.popoverPresentationController!.sourceRect = anchorViewFrame // Assingment is after the rendering, so does not work here
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("DidLayout: \(self.anchorViewFrame.debugDescription) \(String(describing: self.popoverPresentationController!.delegate))")
    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("UpdateViewConstraints")
    }

    /**
     UIContentContainer: Responding to Environment Changes
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("WillRotate")
        let targetOrientationKey: UInt = self.orientation[(size.height > size.width) ? Int(1) : Int(0)].rawValue
        let oppositeKey: UInt = self.orientation[!(size.height > size.width) ? Int(1) : Int(0)].rawValue
        if anchorViewFrameCollection[targetOrientationKey] == nil{
            if anchorViewFrameCollection.isEmpty {
                anchorViewFrameCollection[targetOrientationKey] = anchorViewFrame
            }
            else{
                anchorViewFrameCollection[targetOrientationKey] = CGRect()
            }
        }
        else{
            anchorViewFrameCollection[oppositeKey] = anchorViewFrame
            self.popoverPresentationController!.sourceRect = anchorViewFrameCollection[targetOrientationKey]!
        }
        print(anchorViewFrameCollection)
    }
}

class ModalPresentationHostingController<Content>: UIViewController, UIPopoverPresentationControllerDelegate where Content: View{
    
    private var viewControllerFromView: UIHostingController<Content>?
    private var anchorViewFrame: Binding<CGRect>?
    private var presentingView: UIView?
    private var orientationOptions: [UIInterfaceOrientationMask]?
    private var anchorViewFrameCollection: [UInt:CGRect]?
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    init(presentView: () -> Content, as modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle){
        super.init(nibName: nil, bundle: nil)
        viewControllerFromView = UIHostingController(rootView: presentView())
        viewControllerFromView!.modalPresentationStyle = modalPresentationStyle
        viewControllerFromView!.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = .overFullScreen
    }
    
    convenience init(presentView: () -> Content, as modalPresentationStyle: UIModalPresentationStyle = .popover, withTransition modalTransitionStyle: UIModalTransitionStyle, fromPresentingView presentingView: UIView, appearingFrom anchorViewFrame: Binding<CGRect>){
        self.init(presentView: presentView, as: modalPresentationStyle, withTransition: modalTransitionStyle)
        self.anchorViewFrame = anchorViewFrame
        self.presentingView = presentingView
        self.orientationOptions = [.landscape, .portrait]
        self.anchorViewFrameCollection = [:]
        if let viewPopoverPresentationController = viewControllerFromView!.popoverPresentationController {
            viewPopoverPresentationController.configureAnchorPoint(presentingView: self.presentingView!, anchorViewFrame: self.anchorViewFrame!.wrappedValue)
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
        self.view.backgroundColor = .black.withAlphaComponent(0.6)
        present(viewControllerFromView!, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /**
     UIContentContainer: Responding to Environment Changes
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if (anchorViewFrameCollection != nil){
            let targetOrientationKey: UInt = self.orientationOptions![(size.height > size.width) ? Int(1) : Int(0)].rawValue
            let oppositeKey: UInt = self.orientationOptions![!(size.height > size.width) ? Int(1) : Int(0)].rawValue
            if anchorViewFrameCollection!.isEmpty{
                anchorViewFrameCollection![oppositeKey] = anchorViewFrame!.wrappedValue
                presentedViewController?.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.37){ [self] in
                    viewControllerFromView!.popoverPresentationController?.configureAnchorPoint(presentingView: presentingView!, anchorViewFrame: anchorViewFrame!.wrappedValue)
                    present(viewControllerFromView!, animated: true, completion: nil)
                }
            }
            else {
                anchorViewFrameCollection![oppositeKey] = anchorViewFrame!.wrappedValue
                self.viewControllerFromView!.popoverPresentationController?.sourceRect = anchorViewFrameCollection![targetOrientationKey]!
            }
        }
    }
}
    // TODO: Define behaviour of dismiss in new class ModalPresentationHostingController
    // TODO: Integrate UIPopoverPresentationControllerDelegate behaviour in new class
    // TODO: Try to ignore adaptation of popover to sheet in iphones
extension View{
    
    private func getImmediateAboveViewController() -> UIViewController {
        let windowScene:UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        var immediateAboveViewController:UIViewController = (windowScene.keyWindow?.rootViewController)!
        while let newViewController = immediateAboveViewController.presentedViewController{
            immediateAboveViewController = newViewController
        }
        immediateAboveViewController.modalPresentationCapturesStatusBarAppearance = true
//        immediateAboveViewController.definesPresentationContext = true
//        immediateAboveViewController.providesPresentationContextTransitionStyle = true
        return immediateAboveViewController
    }
    /*
    func presentModallyAs(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        
        if isPresented.wrappedValue{
            let windowScene:UIWindowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            var topViewController:UIViewController = (windowScene.keyWindow?.rootViewController)!
            while let newTopViewController = topViewController.presentedViewController{
                topViewController = newTopViewController
            }
            topViewController.modalPresentationCapturesStatusBarAppearance = true
            topViewController.definesPresentationContext = true
            topViewController.providesPresentationContextTransitionStyle = true
            
            let viewControllerFromView = UIHostingController(rootView: self)
            viewControllerFromView.modalPresentationStyle = modalPresentationStyle
            viewControllerFromView.modalTransitionStyle = modalTransitionStyle
            
            topViewController.present(viewControllerFromView, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isPresented.wrappedValue = false
            }
        }
        return EmptyView()
    }
     */
    // TODO: try to have just one declaration of presentModallyAs()
    func presentModallyAs<Closure>(_ modalPresentationStyle: UIModalPresentationStyle, withTransition modalTransitionStyle: UIModalTransitionStyle, when isPresented: Binding<Bool>, onDismiss: (() -> Void) = {}, appearingFrom anchorViewFrame: Binding<CGRect> = Binding.constant(CGRect()), content closure: @escaping () -> Closure) -> some View where Closure: View{
        
        if modalTransitionStyle == .partialCurl{
            print("Error: presentModallyAs does not support UIModalTransitionStyle.partialCurl because behaviour is unexpected")
        }
        else if isPresented.wrappedValue{
            let topViewController = getImmediateAboveViewController()

            /*
            withExtendedLifetime(popoverDelegate){
                let popoverViewControllerFromView = PopoverHostingController(anchorViewFrame: anchorViewFrame, rootView: closure())
                popoverViewControllerFromView.modalPresentationStyle = modalPresentationStyle
                popoverViewControllerFromView.modalTransitionStyle = modalTransitionStyle
                topViewController.view.alpha = 0.3
                topViewController.present(popoverViewControllerFromView, animated: true, completion: nil)
                popoverViewControllerFromView.popoverPresentationController!.delegate = popoverDelegate
                popoverViewControllerFromView.popoverPresentationController!.sourceView = topViewController.view
                popoverViewControllerFromView.popoverPresentationController!.sourceRect = CGRect(origin: anchorViewFrame.wrappedValue.origin, size: anchorViewFrame.wrappedValue.size)
                popoverViewControllerFromView.popoverPresentationController!.saveDelegate()
                print("**** In presentModallyAs: \(popoverViewControllerFromView.popoverPresentationController!.delegate!)")
            }
            
//            let viewControllerFromView = UIHostingController(rootView: closure())
            let viewControllerFromView = PopoverHostingController(anchorViewFrame: anchorViewFrame!, rootView: closure())
            viewControllerFromView.modalPresentationStyle = modalPresentationStyle
            viewControllerFromView.modalTransitionStyle = modalTransitionStyle
            
            if let viewPopoverPresentationController = viewControllerFromView.popoverPresentationController {
                viewPopoverPresentationController.sourceView = topViewController.view
                viewPopoverPresentationController.sourceRect = CGRect(origin: anchorViewFrame.wrappedValue.origin, size: anchorViewFrame.wrappedValue.size)
//                let popoverDelegate = PopoverDelegate(anchorViewFrame)
//                viewPopoverPresentationController.delegate = popoverDelegate // Assignment doesn't work
            }
//            topViewController.present(viewControllerFromView, animated: true, completion: nil)
             */
            
            var modalViewControllerFromView = ModalPresentationHostingController(presentView: closure, as: modalPresentationStyle, withTransition: modalTransitionStyle)
            if anchorViewFrame.wrappedValue != CGRect() {
                modalViewControllerFromView = ModalPresentationHostingController(presentView: closure, as: modalPresentationStyle, withTransition: modalTransitionStyle, fromPresentingView: topViewController.view, appearingFrom: anchorViewFrame)
            }
            
            topViewController.present(modalViewControllerFromView, animated: false, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                isPresented.wrappedValue = false
            }
        }
        return self
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

struct GeometryProxyTracker<Content: View>: View {
    var closure: (GeometryProxy) -> ()
    var content: (GeometryProxy) -> (Content)
    
    private func setGeometryProxy(_ geometryProxy: GeometryProxy) -> EmptyView {
        closure(geometryProxy)
        return EmptyView()
    }
    
    var body: some View{
        GeometryReader { geometryProxy in
            VStack{
                self.setGeometryProxy(geometryProxy)
                self.content(geometryProxy)
            }
        }
    }
}

struct LoadingView: View {
    
    @EnvironmentObject var appState: AppStateModel
    @State private var showSettings: Bool = false
    @State private var anchorViewFrame: CGRect = CGRect()
    
    var body: some View {
        VStack() {
            Spacer()
            Text("Loading . . .")
                .font(.title).bold()
                .onAppear(perform: {
                    if !appState.btConnectionSuccessful {
                        showSettings.toggle()
                    }
                })
            /*
            SettingsView()
                .interactiveDismissDisabled()
                .environmentObject(appState)
//                .modifier(ForNewFullScreenRootView(AppStateInstance: appState))
                .presentModallyAs(.formSheet, withTransition: .coverVertical, when: $showSettings)
             */
                .overlay(
                    /*
                    GeometryProxyTracker(closure: {
                        anchorViewFrame = $0.frame(in: .global)
                        print("GeometryProxyTracker closure: \(anchorViewFrame)")
                    }) { geometryProxy in
                        Color.clear
                            .onAppear(perform: {
                                anchorViewFrame = geometryProxy.frame(in: .global)
//                                print(anchorViewFrame)
                            })
                            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                                anchorViewFrame = geometryProxy.frame(in: .global)
                                print("OnReceivefunc: \(anchorViewFrame)")
                            })
                            .presentModallyAs(.popover, withTransition: .crossDissolve, when: $showSettings, appearingFrom: $anchorViewFrame){
                                SettingsView()
                                    .interactiveDismissDisabled()
                                    .environmentObject(appState)
                            }
                    }
                    */
                    
                    GeometryReader { geometryProxy in
                        Color.clear
                            .onAppear(perform: {
                                anchorViewFrame = geometryProxy.frame(in: .global)
//                                print(anchorViewFrame)
                            })
                            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                                anchorViewFrame = geometryProxy.frame(in: .global)
                                print("OnReceivefunc: \(anchorViewFrame)")
                            })
//                            .presentModallyAs(.popover, withTransition: .crossDissolve, when: $showSettings, appearingFrom: $anchorViewFrame){
//                                SettingsView()
//                                    .interactiveDismissDisabled()
//                                    .environmentObject(appState)
//                            }
                        
                            .presentModallyAs(.automatic, withTransition: .coverVertical, when: $showSettings){
                                SettingsView()
                                    .interactiveDismissDisabled()
                                    .environmentObject(appState)
//                                    .modifier(ForNewFullScreenRootView(AppStateInstance: appState))
                            }
                    }
                    
                )
            Color.clear
                .frame(height: 33)
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
