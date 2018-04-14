//
//  Picture.swift
//  NotePro
//
//  Created by Araceli Teixeira on 06/04/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import MapKit

public class Picture: Equatable {
    public private(set) var pictureId: Int?
    public private(set) var noteId: Int?
    public private(set) var picture: UIImage
    public private(set) var path: String
    
    init(_ picture: UIImage) {
        self.picture = picture
        self.path = ""
    }
    
    init(_ path: String) {
        self.picture = UIImage()
        self.path = path
    }
    
    init(_ picture: UIImage, _ path: String) {
        self.picture = picture
        self.path = path
    }
    
    init(_ pictureId: Int, _ noteId: Int, _ picture: UIImage) {
        self.pictureId = pictureId
        self.noteId = noteId
        self.picture = picture
        self.path = ""
    }
    
    init(_ pictureId: Int, _ noteId: Int, _ path: String) {
        self.pictureId = pictureId
        self.noteId = noteId
        self.picture = UIImage()
        self.path = path
    }
    
    public static func ==(lhs: Picture, rhs: Picture) -> Bool {
        return lhs.pictureId == rhs.pictureId && lhs.noteId == rhs.noteId
    }
}
