//
//  NoteController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import CoreLocation

internal class NoteController {
    private let databaseController: DatabaseController
    private var subject: Subject?
    private var originalNoteList: [Note]
    
    internal fileprivate(set) var noteList: [Note] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        noteList = []
        originalNoteList = []

        databaseController = DatabaseController()
        
        /*let subjectsList = databaseController.selectSubjects()
        var count = 0
        let location = CLLocationCoordinate2D(latitude: 43.773263, longitude: -79.335923)
        let pictures: [Picture] = []
        
        for eachSub in subjectsList {
            noteList.append(Note(count,"Note Exemplo Sub \(eachSub.subjectId)", "description \(eachSub.subjectId)", eachSub, Date(), location, pictures))
            noteList.append(Note(count+1,"Note Exemplo Sub \(eachSub.subjectId)", "description \(eachSub.subjectId)", eachSub, Date(), location, pictures))
            count += 2
        }
        for note in noteList {
            databaseController.addNote(note)
            print("adicionou \(note.noteId)")
        }
        fetchNotes(nil)*/
    }
    
    internal func getNotes() -> [Note] {
        return noteList
    }
    
    internal func getNotesBySubject(_ subject: Subject) -> [Note] {
        return databaseController.selectNotesBySubject(subject)
    }
    
    internal func fetchNotes(_ subject: Subject?) {
        self.subject = subject
        if let subject = subject {
            noteList = databaseController.selectNotesBySubject(subject)
        } else {
            noteList = databaseController.selectNotes()
        }
        originalNoteList = noteList
    }
    
    public func saveNote(_ note: Note) {
        if note.noteId < 0 {
            databaseController.addNote(note)
        } else {
            databaseController.updateNote(note)
            updatePhotos(note)
        }
        fetchNotes(note.subject)
    }
    
    public func deleteNote(_ note: Note) {
        databaseController.deleteNote(note)
        databaseController.deletePicturesByNoteId(note.noteId)
    }
    
    public func updatePhotos(_ note: Note) {
        var picturesInDB = databaseController.selectPicturesByNoteId(note.noteId)
        for photo in note.photos {
            let index = picturesInDB.index(of: photo)
            if index == nil { // if photo ins't in db, insert it
                databaseController.addPicture(note.noteId, photo.picture)
            } else { // if photo is in db, remove it from the list
                picturesInDB.remove(at: index!)
            }
        }
        for picture in picturesInDB { // remaining pictures are to be deleted
            guard let pictureId = picture.pictureId else {
                print("PictureId does not exist")
                return
            }
            databaseController.deletePicture(pictureId)
        }
    }
    
    public func sortNoteByTitle(_ order: Bool) {
        if order {
            noteList = noteList.sorted(by: {
                $0.title > $1.title
            })
        } else {
            noteList = noteList.sorted(by: {
                $0.title < $1.title
            })
        }
    }
    public func sortNoteByDate(_ order: Bool) {
        if order {
            noteList = noteList.sorted(by: {
                $0.dateTime > $1.dateTime
            })
        } else {
            noteList = noteList.sorted(by: {
                $0.dateTime < $1.dateTime
            })
        }
    }
    public func searchNoteByTitle(_ search: String, _ subject: Subject?) {
        noteList = databaseController.selectNotesByTitle(search, subject)
    }
    public func searchNoteByKeyword(_ search: String, _ subject: Subject?) {
        noteList = databaseController.selectNotesByKeyword(search, subject)
    }
    
}
