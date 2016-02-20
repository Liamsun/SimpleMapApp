//
//  MapDetailViewController.swift
//  Trax
//
//  Created by Sun liang on 2/14/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit
import MapKit

class MapDetailViewController: UIViewController {
    var mapView: MKMapView!
    
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
