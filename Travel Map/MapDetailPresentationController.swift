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
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        self.presentedViewFrame = presentedViewController.view.frame
        super.init(presentedViewController:presentedViewController, presentingViewController:presentingViewController)
        chromeView.backgroundColor = UIColor(white:0.0, alpha:0.4)
        chromeView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: "chromeViewTapped:")
        chromeView.addGestureRecognizer(tap)
    }
    
    func chromeViewTapped(gesture: UIGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Ended) {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView!.bounds
        presentedViewFrame.size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        
        return presentedViewFrame
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        //return self.presentedViewFrame.size
        return CGSizeMake(parentSize.width, CGFloat((floorf(Float(parentSize.height / 3.54)))))
    }
    
    override func presentationTransitionWillBegin() {
        chromeView.frame = self.containerView!.bounds
        chromeView.alpha = 0.0
        containerView!.insertSubview(chromeView, atIndex:0)
        let coordinator = presentedViewController.transitionCoordinator()
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
            }, completion:nil)
        } else {
            chromeView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator()
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 0.0
            }, completion:nil)
        } else {
            chromeView.alpha = 0.0
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool)  {
        // If the presentation didn't complete, remove the chrome view
        if !completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        // If the dismissal completed, remove the dimming view
        if completed {
            chromeView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerView!.bounds
        presentedView()!.frame = frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.OverFullScreen
//    }
   
}
