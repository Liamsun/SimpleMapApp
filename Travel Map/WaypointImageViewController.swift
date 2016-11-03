//
//  WaypointImageViewController.swift
//  Trax
//
//  Created by Sun liang on 2/2/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {

    var waypoint: GPX.Waypoint? {
        didSet {
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            updateEmbeddedMap()
        }
    }
    
    var smvc: SimpleMapViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Embed Segue" {
            smvc = segue.destination as? SimpleMapViewController
            updateEmbeddedMap()
        }
    }
    
    func updateEmbeddedMap() {
        if let mapView = smvc?.mapView {
            mapView.mapType = .hybrid
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(waypoint!)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

}
