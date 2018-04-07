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
    
    internal fileprivate(set) var noteList: [Note] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        }
    }
    
    init() {
        noteList = []
        databaseController = DatabaseController()
        /*let subjectsList = databaseController.selectSubjects()
        var count = 0
        let location = CLLocationCoordinate2D(latitude: 43.773263, longitude: -79.335923)
        let pictures: [Picture] = []
        
        for eachSub in subjectsList {
            noteList.append(Note(count,"Note Exemplo Sub \(eachSub.subjectId)", "description \(eachSub.subjectId)", eachSub, Date(), location, "address qlqr", pictures))
            noteList.append(Note(count+1,"Note Exemplo Sub \(eachSub.subjectId)", "description \(eachSub.subjectId)", eachSub, Date(), location, "address qlqr", pictures))
            count += 2
        }
        for note in noteList {
            databaseController.addNote(note)
            print("adicionou \(note.noteId)")
        }
        fetchNotes()*/
    }
    
    internal func getAllNotes() -> [Note] {
        return noteList
    }
    
    internal func getNotesBySubject(_ subject: Subject) -> [Note] {
        return databaseController.selectNotesBySubject(subject)
    }
    
    internal func fetchNotes() {
        noteList = databaseController.selectNotes()
    }
    
    public func saveNote(_ note: Note) {
        if note.noteId < 0 {
            databaseController.addNote(note)
        } else {
            databaseController.updateNote(note)
            updatePhotos(note)
        }
        fetchNotes()
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
            databaseController.deletePicture(picture.pictureId)
        }
    }
}
