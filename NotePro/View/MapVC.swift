//
//  MapVC.swift
//  NotePro
//
//  Created by Amanda Rosa on 2018-04-06.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    let annotation = MKPointAnnotation()
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let location = location {
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        } else {
            print("Error to set the note location")
        }
       
        mapView.addAnnotation(annotation)
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, regionRadius, regionRadius)
        mapView.setRegion (coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
