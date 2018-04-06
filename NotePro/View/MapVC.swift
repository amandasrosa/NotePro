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
    //let note: Note
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        //annotation.coordinate = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
        annotation.coordinate = CLLocationCoordinate2D(latitude:  43.773263, longitude: -79.335923)
       
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
