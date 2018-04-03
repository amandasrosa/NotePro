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
    private let noteController: NoteController
    private let databaseController: DatabaseController
    
    // MARK: Entities
    public var subjects: [Subject] {
        return self.subjectController.getSubjects()
    }
    
    public var notes: [Note] {
        return self.noteController.getAllNotes()
    }

    private init() {
        self.subjectController = SubjectController()
        self.noteController = NoteController()
        self.databaseController = DatabaseController()
    }
    
    // MARK: Public Methods
    public func fetchSubjectList() {
        return self.subjectController.fetchSubjects()
    }
    
    public func getSubjectList() -> [Subject] {
        return self.subjectController.getSubjects()
    }
    
    public func fetchNoteList() {
        return self.noteController.fetchNotes()
    }
    
    public func getNotesBySubject(_ subject: Subject) -> [Note] {
        return self.noteController.getNotesBySubject(subject)
    }
    
    public func createTables() {
        return self.databaseController.createTables()
    }
    
    public func selectSubjects() -> [Subject] {
        return self.databaseController.selectSubjects()
    }
    
    public func saveSubject(_ subject: Subject) {
        return self.databaseController.addSubject(subject)
    }
    
    public func selectNotesBySybject(_ subject: Subject) -> [Note] {
        return self.databaseController.selectNotesBySubject(subject)
    }
    
    public func selectNotes() -> [Note] {
        return self.databaseController.selectNotes()
    }
    
    public func saveSubject(_ note: Note) {
        return self.databaseController.addNote(note)
    }
}
