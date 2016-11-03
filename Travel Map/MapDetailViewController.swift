//
//  MapDetailViewController.swift
//  Trax
//
//  Created by Sun liang on 2/14/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit
import MapKit

class MapDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var mapView: MKMapView!
    
    // MARK: segment
    @IBOutlet weak var mapType: UISegmentedControl!
    
    @IBAction func configureMap(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        switch selectedIndex {
        case 0: mapView.mapType = .Standard
        case 1: mapView.mapType = .HybridFlyover
        case 2: mapView.mapType = .SatelliteFlyover
        default: break
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MAKR: table view
    @IBOutlet weak var tableView: UITableView!

    var detailsForMapType = [String]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsForMapType.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MapDetailTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MapDetailTableViewCell
        cell.mapDetails.text = detailsForMapType[indexPath.row]
        // set up cell
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case 0 :
            mapView.showsPointsOfInterest = !mapView.showsPointsOfInterest
        case 1 :
            mapView.showsTraffic = !mapView.showsTraffic
        case 2 :
            let mapCameraPitch: CGFloat = mapView.camera.pitch > 0 ? 0 : 60
            mapView.camera.pitch = mapCameraPitch
        default: break
        }
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
    }
    
    func loadDetails() {
        let currentMapType = mapView.mapType
        var selectedIndex = 0
        switch currentMapType {
        case MKMapType.Standard:
            selectedIndex = 0
            setMapDetails()
            
            
        case MKMapType.HybridFlyover:
            selectedIndex = 1
            setMapDetails()
            
            // do something later
            
        case MKMapType.SatelliteFlyover:
            selectedIndex = 2
            //setMapDetails()
            
        default: break
        }
        
        mapType.selectedSegmentIndex = selectedIndex
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setMapDetails() {
        var tmp: String
        
        // show or hide label
        tmp = mapView.showsPointsOfInterest ? "Hide Label" : "Show Label"
        detailsForMapType.append(tmp)
        
        // show or hide traffic
        tmp = mapView.showsTraffic ? "Hide Traffic" : "Show Traffic"
        detailsForMapType.append(tmp)
        
        // show 2D or 3D
        tmp = mapView.camera.pitch > 0 ? "2D Map" : "3D Map"
        detailsForMapType.append(tmp)
    }
}
