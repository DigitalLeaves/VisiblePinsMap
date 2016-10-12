//
//  CLLocationCoordinate2D+Equality.swift
//  VisiblePinsMap
//
//  Created by Ignacio Nieto Carvajal on 12/10/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation
import CoreLocation

private let kCLLocationCoordinateErrorRange = 0.005

extension CLLocationCoordinate2D {
    func isEqual(object: Any) -> Bool {
        if let coordinate = object as? CLLocationCoordinate2D { return self == coordinate }
        return false
    }
}
func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    if abs(lhs.latitude - rhs.latitude) > kCLLocationCoordinateErrorRange { return false }
    else if abs(lhs.longitude - rhs.longitude) > kCLLocationCoordinateErrorRange { return false }
    return true
}
