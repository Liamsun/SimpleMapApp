//
//  MapTypeViewController.swift
//  PresentationControllers
//
//  Created by Sun liang on 2/7/16.
//  Copyright © 2016 Dative Studios. All rights reserved.
//

import UIKit
import MapKit

class MapTypeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var mapView: MKMapView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    
    @IBOutlet weak var mapTypeBeforeChanged: UISegmentedControl!
    
    @IBAction func configureMap(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        switch selectedIndex {
        case 0: mapView.mapType = .Standard
        case 1: mapView.mapType = .Satellite
        case 2: mapView.mapType = .Hybrid
        default: return
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        sender.selectedSegmentIndex = -1
    }
    
    // ---- UIViewControllerTransitioningDelegate methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
        }
        
        return nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return CustomPresentationAnimationController(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return CustomPresentationAnimationController(isPresenting: false)
        }
        else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentMapType = mapView.mapType
        var selectedIndex = 0
        switch currentMapType {
        case MKMapType.Standard: selectedIndex = 0
        case MKMapType.Satellite: selectedIndex = 1
        case MKMapType.Hybrid: selectedIndex = 2
        default: selectedIndex = -1
        }
        
        mapTypeBeforeChanged.selectedSegmentIndex = selectedIndex
    }
}
