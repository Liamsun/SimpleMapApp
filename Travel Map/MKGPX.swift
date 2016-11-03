//
//  MKGPX.swift
//  Trax
//
//  Created by Sun liang on 1/30/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import MapKit

class EditableWaypoint: GPX.Waypoint
{
    override var coordinate: CLLocationCoordinate2D {
        get { return super.coordinate }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    override var thumbnailURL: URL? { return imageURL }
    override var imageURL: URL? { return links.first?.url as URL? }
    
}

extension GPX.Waypoint: MKAnnotation
{
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return info
    }
    
    var thumbnailURL: URL? { return getImageURLofType("thumbnail") }
    var imageURL: URL? { return getImageURLofType("large") }
    
    fileprivate func getImageURLofType(_ type: String) -> URL? {
        for link in links {
            if link.type == type {
                return link.url as URL?
            }
        }
        return nil
    }
}
