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
        return self.noteController.getNotes()
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
    
    public func fetchNoteList(_ subject: Subject?) {
        return self.noteController.fetchNotes(subject)
    }
    
    public func initDatabase() {
        return self.databaseController.initDatabase()
    }
    
    public func saveSubject(_ subject: Subject) {
        return self.subjectController.saveSubject(subject)
    }
    
    public func deleteSubject(_ subject: Subject) {
        return self.subjectController.deleteSubject(subject)
    }
    
    public func saveNote(_ note: Note) {
        return self.noteController.saveNote(note)
    }
    
    public func deleteNote(_ note: Note) {
        return self.noteController.deleteNote(note)
    }
    
    public func sortNoteByTitle() {
        return self.noteController.sortNoteByTitle()
    }
    
    public func sortNoteByDate() {
        return self.noteController.sortNoteByDate()
    }
    
    public func searchNoteByTitle(_ search: String, _ subject: Subject?) {
        return self.noteController.searchNoteByTitle(search, subject)
    }
    
    public func searchNoteByKeyword(_ search: String, _ subject: Subject?) {
        return self.noteController.searchNoteByKeyword(search, subject)
    }
    
}
