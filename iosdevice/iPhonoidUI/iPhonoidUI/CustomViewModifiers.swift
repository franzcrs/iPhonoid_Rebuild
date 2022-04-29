//  
//  CustomViewModifiers.swift
//  
//  *Describe purpose*
//  
//  Version: 0.2
//  Written using Swift 5.0
//  Created by Franz Chuquirachi (@franzcrs) on 2022/03/15
//  Copyright © 2022. All rights reserved.
//  

import SwiftUI

struct ForNewFullScreenRootView: ViewModifier {
    
    var AppStateInstance: AppStateModel
    
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(.container, edges: .all)
            .statusBar(hidden: true)
            .environmentObject(AppStateInstance)
    }
}

struct PresentModallyAsModifier<ModalContent>: ViewModifier where ModalContent: View {
    
    var modalPresentationStyle: UIModalPresentationStyle
    var modalTransitionStyle: UIModalTransitionStyle
    var isPresented: Binding<Bool>
    var modalContent: () -> ModalContent
    var onDismiss: () -> Void
    
    var anchorView = UIView()
    
    private func presentModal() {
        let sourceVC = EmptyView().getCurrentlyPresentedVC()
        let viewControllerFromView = ModalPresentationHostingController(isPresented: isPresented, onDismiss: onDismiss, rootView: modalContent())
        viewControllerFromView.modalPresentationStyle = modalPresentationStyle
        viewControllerFromView.modalTransitionStyle = modalTransitionStyle
        if let popover = viewControllerFromView.popoverPresentationController {
            popover.delegate = viewControllerFromView
            popover.sourceView = anchorView
            popover.sourceRect = anchorView.bounds
        }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                    sourceVC.present(viewControllerFromView, animated: true, completion: nil)
            }
        } else {
                sourceVC.present(viewControllerFromView, animated: true, completion: nil)
        }
    }
    
    //SwiftUI wrapper for transforming the UIView into a SwiftUI view
    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView
        
        func makeUIView(context: Self.Context) -> Self.UIViewType {
            uiView
        }
        
        func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
    }
    
    func body(content: Content) -> some View {
        if modalTransitionStyle == .partialCurl{
            print("Error: presentModallyAs does not support UIModalTransitionStyle.partialCurl because behaviour of that transition style is unexpected")
        }
        else if isPresented.wrappedValue {
            // Do not run this statement at the same time the modifed View is rendering for the first time, otherwise the uiView parameters will have value 0
            presentModal()
        }
        
        return content
        // Adding a UIView as background will resize itself to the anchor view in the SwiftUI structure
            .background(InternalAnchorView(uiView: anchorView))
    }
}

class ModalPresentationHostingController<Content>: UIHostingController<Content>, UIPopoverPresentationControllerDelegate where Content: View {
    
    var isPresented: Binding<Bool>
    let onDismiss: () -> Void
    
    required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void, rootView: Content) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController!.view.alpha = 0.4
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController!.view.alpha = 1
        self.isPresented.wrappedValue = false
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
