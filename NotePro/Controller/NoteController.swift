//
//  NoteController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

internal class NoteController {
    private let databaseController: DatabaseController
    
    internal fileprivate(set) var noteList: [Note] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        noteList = []
        databaseController = DatabaseController()
    }
    
    internal func getAllNotes() -> [Note] {
        return noteList
    }
    
    internal func getNotesBySubject(_ subject: Subject) -> [Note] {
        return self.databaseController.selectNotesBySubject(subject)
    }
    
    internal func fetchNotes() {
        noteList = self.databaseController.selectNotes()
    }
    
    public func saveNote(_ note: Note) {
        if note.noteId < 0 {
            self.databaseController.addNote(note)
        } else {
            self.databaseController.updateNote(note)
        }
        self.fetchNotes()
    }
    
    public func deleteNote(_ note: Note) {
        self.databaseController.deleteNote(note)
    }
}
