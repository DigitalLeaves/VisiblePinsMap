//
//  ViewController.swift
//  VisiblePinsMap
//
//  Created by Ignacio Nieto Carvajal on 9/10/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import MapKit

private let kVisiblePinsMapPinName = "VisiblePinsMapPin"
private let kVisiblePinsMapPinImage = UIImage(named: "museumPin")!

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    // outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    // data
    var poi: [PointOfInterest] = [] {
        didSet { visiblePOI = poi; filterVisiblePOI() }
    }
    var visiblePOI: [PointOfInterest] = []
    let userLocation = CLLocationCoordinate2D(latitude: 38.88833, longitude: -77.01639) // fake user location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPointsOfInterest()
        centerMapInInitialCoordinates()
        showPointsOfInterestInMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filterVisiblePOI()
    }
    
    // MARK: - Map related information loading and positioning.
    
    func showPointsOfInterestInMap() {
        mapView.removeAnnotations(mapView.annotations)

        for point in poi {
            let pin = POIAnnotation(point: point)
            mapView.addAnnotation(pin)
        }
    }
    
    func centerMapInInitialCoordinates() {
        // fixed user location at latitude: -77.01639, longitude: 38.88833
        mapView.setCenter(userLocation, animated: true)
        let visibleRegion = MKCoordinateRegionMakeWithDistance(userLocation, 100000, 100000)
        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)

    }
    
    func loadPointsOfInterest() {
        guard let poiPath = Bundle.main.path(forResource: "museums_usa", ofType: "csv") else {
            print("Unable to find POI file in App's bundle.")
            return
        }
        guard let poiData = FileManager.default.contents(atPath: poiPath) else {
            print("Error getting data from POI file at \(poiPath)")
            return
        }
        
        guard let poiString = String(data: poiData, encoding: String.Encoding.utf8) else {
            print("Unable to get a valid string from data in POI file \(poiPath)")
            return
        }
        
        for line in poiString.components(separatedBy: "\n") {
            if let point = PointOfInterest(csvLine: line) { poi.append(point) }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kVisiblePinsMapPinName)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kVisiblePinsMapPinName)
            annotationView!.canShowCallout = true
            annotationView!.image = kVisiblePinsMapPinImage
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
        
    }
    
    // MARK: - Basic table data loading methods.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visiblePOI.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointOfInterestCell", for: indexPath)
        
        // configure cell
        let point = visiblePOI[indexPath.row]
        cell.textLabel?.text = point.name
        cell.detailTextLabel?.text = "(\(point.coordinate.latitude), \(point.coordinate.longitude))"
        
        return cell
    }
    
    // MARK: - Selecting elements in the list selects the related map pin.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = visiblePOI[indexPath.row]
        if let annotation = (mapView.annotations as? [POIAnnotation])?.filter({ $0.pointOfInterest == point }).first {
            selectPinPointInTheMap(annotation: annotation)
        }
    }
    
    func selectPinPointInTheMap(annotation: POIAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        if CLLocationCoordinate2DIsValid(annotation.coordinate) {
            self.mapView.setCenter(annotation.coordinate, animated: true)
        }
    }
    
    // MARK: - Filtering list to the pins shown at the map.
    
    func filterVisiblePOI() {
        let visibleAnnotations = self.mapView.annotations(in: self.mapView.visibleMapRect)
        var annotations = [POIAnnotation]()
        for visibleAnnotation in visibleAnnotations {
            if let annotation = visibleAnnotation as? POIAnnotation {
                annotations.append(annotation)
            }
        }
        self.visiblePOI = annotations.map({$0.pointOfInterest})
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        filterVisiblePOI()
    }
    
}

