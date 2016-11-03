//
//  ExamplePresentationController.swift
//  PresentationsDemo
//
//  Created by Joyce Echessa on 5/29/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class MapDetailPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    var chromeView: UIView = UIView()
    let presentedViewFrame: CGRect
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.presentedViewFrame = presentedViewController.view.frame
        super.init(presentedViewController:presentedViewController, presenting:presentingViewController)
        chromeView.backgroundColor = UIColor(white:0.0, alpha:0.4)
        chromeView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MapDetailPresentationController.chromeViewTapped(_:)))
        chromeView.addGestureRecognizer(tap)
    }
    
    func chromeViewTapped(_ gesture: UIGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.ended) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        var presentedViewFrame = CGRect.zero
        let containerBounds = containerView!.bounds
        presentedViewFrame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        
        return presentedViewFrame
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        //return self.presentedViewFrame.size
        return CGSize(width: parentSize.width, height: CGFloat((floorf(Float(parentSize.height / 3.54)))))
    }
    
    override func presentationTransitionWillBegin() {
        chromeView.frame = self.containerView!.bounds
        chromeView.alpha = 0.0
        containerView!.insertSubview(chromeView, at:0)
        let coordinator = presentedViewController.transitionCoordinator
        if (coordinator != nil) {
            coordinator!.animate(alongsideTransition: {
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
            }, completion:nil)
        } else {
            chromeView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator
        if (coordinator != nil) {
            coordinator!.animate(alongsideTransition: {
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 0.0
            }, completion:nil)
        } else {
            chromeView.alpha = 0.0
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)  {
        // If the presentation didn't complete, remove the chrome view
        if !completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // If the dismissal completed, remove the dimming view
        if completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen : Bool {
        return true
    }
    
    override var adaptivePresentationStyle : UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.OverFullScreen
//    }
   
}
