//
//  POIAnnotation.swift
//  VisiblePinsMap
//
//  Created by Ignacio Nieto Carvajal on 11/10/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation
import MapKit

class POIAnnotation: NSObject, MKAnnotation {
    let pointOfInterest: PointOfInterest
    var coordinate: CLLocationCoordinate2D { return pointOfInterest.coordinate }
    
    init(point: PointOfInterest) {
        self.pointOfInterest = point
        super.init()
    }
    
    var title: String? {
        return pointOfInterest.name
    }
    
    var subtitle: String? {
        return "(\(pointOfInterest.coordinate.latitude), \(pointOfInterest.coordinate.longitude))"
    }
}
