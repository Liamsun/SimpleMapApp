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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    
    @IBOutlet weak var mapTypeBeforeChanged: UISegmentedControl!
    
    @IBAction func configureMap(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        switch selectedIndex {
        case 0: mapView.mapType = .standard
        case 1: mapView.mapType = .satellite
        case 2: mapView.mapType = .hybrid
        default: return
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
        sender.selectedSegmentIndex = -1
    }
    
    // ---- UIViewControllerTransitioningDelegate methods
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            return CustomPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return CustomPresentationAnimationController(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
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
        case MKMapType.standard: selectedIndex = 0
        case MKMapType.satellite: selectedIndex = 1
        case MKMapType.hybrid: selectedIndex = 2
        default: selectedIndex = -1
        }
        
        mapTypeBeforeChanged.selectedSegmentIndex = selectedIndex
    }
}
