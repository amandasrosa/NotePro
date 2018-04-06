//
//  SubjectController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

internal class SubjectController {
    private let databaseController: DatabaseController
    
    internal fileprivate(set) var subjectList: [Subject] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_SUBJECT_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        subjectList = []
        databaseController = DatabaseController()
    }
    
    internal func getSubjects() -> [Subject]{
        return subjectList
    }
    
    internal func fetchSubjects() {
        subjectList = self.databaseController.selectSubjects()
    }
    
    public func saveSubject(_ subject: Subject) {
        if subject.subjectId < 0 {
            self.databaseController.addSubject(subject)
        } else {
            self.databaseController.updateSubject(subject)
        }
        self.fetchSubjects()
    }
}
