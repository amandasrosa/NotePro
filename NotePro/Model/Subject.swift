//
//  Subject.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

public class Subject: Equatable {
    public private(set) var subject: String
    public private(set) var color: UIColor
    
    init(_ subject: String, _ color: UIColor) {
        self.subject = subject
        self.color = color
    }
    
    public static func ==(lhs: Subject, rhs: Subject) -> Bool {
        return lhs.subject == rhs.subject
    }
    
    public func setSubject(_ subject: String) {
        self.subject = subject
    }
    
    public func setColor(_ color: UIColor) {
        self.color = color
    }
}
