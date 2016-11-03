//
//  Created by Pete Callaway on 26/06/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import UIKit


class CustomPresentationController: UIPresentationController {

    lazy var dimmingView :UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        view.alpha = 0.0
        return view
    }()

    override func presentationTransitionWillBegin() {

		guard
			let containerView = containerView,
			let presentedView = presentedView
		else {
			return
		}

        // Add the dimming view and the presented view to the heirarchy
        dimmingView.frame = containerView.bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.chromeViewTapped(_:)))
        dimmingView.addGestureRecognizer(tap)
        
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)

        // Fade in the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1.0
            }, completion:nil)
        }
    }
    
    func chromeViewTapped(_ gesture: UIGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.ended) {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool)  {
        // If the presentation didn't complete, remove the dimming view
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin()  {
        // Fade out the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha  = 0.0
            }, completion:nil)
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // If the dismissal completed, remove the dimming view
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView : CGRect {

		guard
			let containerView = containerView
		else {
			return CGRect()
		}

        // We don't want the presented view to fill the whole container view, so inset it's frame
        //var frame = containerView.bounds;
        //frame = CGRectInset(frame, 50.0, 50.0)
        let height = containerView.bounds.height
        let width = containerView.bounds.width
        
        let frame = CGRect(x: 0, y: height-40, width: width, height: 40)

        return frame
    }


    // ---- UIContentContainer protocol methods

    override func viewWillTransition(to size: CGSize, with transitionCoordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: transitionCoordinator)

		guard
			let containerView = containerView
		else {
			return
		}

        transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.frame = containerView.bounds
        }, completion:nil)
    }
}
