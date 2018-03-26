//
//  CoreFacade.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import Foundation

public class CoreFacade {
    // MARK: Singleton
    public static let shared: CoreFacade = CoreFacade()
    
    // MARK: Controllers
    private let subjectController: SubjectController
    
    // MARK: Entities
    public var subjects: [Subject] {
        return self.subjectController.getSubjects()
    }

    private init() {
        self.subjectController = SubjectController()
    }
    
    // MARK: Public Methods
    public func fetchSubjectList() {
        return self.subjectController.fetchSubjects()
    }
    
    public func getSubjectList() -> [Subject] {
        return self.subjectController.getSubjects()
    }
}
