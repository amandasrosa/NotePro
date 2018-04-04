//
//  Note.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import MapKit

public class Note: Equatable {
    public private(set) var noteId: Int = -1
    public private(set) var title: String
    public private(set) var description: String
    public private(set) var subject: Subject
    public private(set) var dateTime: Date
    public private(set) var photos: [UIImage] = []
    public private(set) var location: CLLocationCoordinate2D?
    public private(set) var address: String?
    
    init(_ id: Int, _ title: String, _ description: String, _ subject: Subject, _ dateTime: Date, _ location: CLLocationCoordinate2D, _ address: String) {
        self.noteId = id
        self.title = title
        self.description = description
        self.subject = subject
        self.dateTime = dateTime
    }
    
    init(_ title: String, _ description: String, _ subject: Subject, _ dateTime: Date) {
        self.title = title
        self.description = description
        self.subject = subject
        self.dateTime = dateTime
    }
    
    public static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.title == rhs.title && lhs.description == rhs.description && lhs.subject == rhs.subject
    }
    
    public func setTitle(_ title: String) {
        self.title = title
    }
    public func setdescription(_ description: String) {
        self.description = description
    }
    public func setsubject(_ subject: Subject) {
        self.subject = subject
    }
    public func setdateTime(_ dateTime: Date) {
        self.dateTime = dateTime
    }
    public func setphotos(_ photos: [UIImage]) {
        self.photos = photos
    }
    public func setlocation(_ location: CLLocationCoordinate2D) {
        self.location = location
    }
    public func setaddress(_ address: String) {
        self.address = address
    }

}
