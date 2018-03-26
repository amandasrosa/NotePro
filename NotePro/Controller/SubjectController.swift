//
//  SubjectController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

internal class SubjectController {
    internal fileprivate(set) var subjectList: [Subject] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_SUBJECT_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        subjectList = []
    }
    
    internal func getSubjects() -> [Subject]{
        return subjectList
    }
    
    internal func fetchSubjects() {
        let colors = [UIColor.blue, UIColor.orange, UIColor.green]
        for i in (1...3) {
            subjectList.append(Subject("Subject \(i)", colors[i]))
        }
    }
}
