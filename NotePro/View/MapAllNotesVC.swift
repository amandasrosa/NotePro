//
//  MapAllNotesVC.swift
//  NotePro
//
//  Created by Denis Gois on 2018-04-16.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class MapAllNotesVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocationCoordinate2D?
    var annotations = [MKPointAnnotation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        
        CoreFacade.shared.fetchNoteList(nil)
        CoreFacade.shared.notes.forEach { (note) in
            let annotation = MKPointAnnotation()
            if let location = note.location {
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                print("lat: \(location.latitude) | long: \(location.longitude)")
            } else {
                print("Error to set the note location")
            }
            annotations.append(annotation)
        }
        mapView.showAnnotations(annotations, animated: true)
    }
}
