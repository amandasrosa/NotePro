//
//  NoteController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

internal class NoteController {
    internal fileprivate(set) var noteList: [Note] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        noteList = []
    }
    
    internal func getAllNotes() -> [Note] {
        return noteList
    }
    
    internal func getNotesBySubject(_ subject: Subject) -> [Note] {
        var filteredNotes: [Note] = []
        
        for note in noteList {
            if note.subject == subject {
                filteredNotes.append(note)
            }
        }
        
        return filteredNotes
    }
    
    internal func fetchNotes() {
        noteList = []
        createNoteStub()
    }
    
    private func createNoteStub() {
        for subject in createSubjectStub() {
            for i in 1...3 {
                noteList.append(Note("Note \(i)", "Description of note \(i) of \(subject.subject)", subject, Date()))
            }
        }
    }
    
    private func createSubjectStub() -> [Subject] {
        var subjectList: [Subject] = []
        let colors = [UIColor.blue, UIColor.orange, UIColor.green]
        for i in (1...3) {
            subjectList.append(Subject("Subject \(i)", colors[i-1]))
        }
        return subjectList
    }
}
