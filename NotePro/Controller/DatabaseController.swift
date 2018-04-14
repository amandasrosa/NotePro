//
//  DatabaseController.swift
//  NotePro
//
//  Created by Amanda Rosa on 2018-04-02.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import CoreLocation

class DatabaseController: NSObject {

    var database:OpaquePointer? = nil
    var isDatabaseCreated = false
    var isDatabaseOpen = false
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func openDatabase() {
        if !isDatabaseOpen {
            if (sqlite3_open(dataFilePath(), &database) != SQLITE_OK) {
                sqlite3_close(database)
                print("Failed to open database")
                return
            }
            isDatabaseOpen = true
        }
    }
    
    func closeDatabase() {
        if isDatabaseOpen {
            sqlite3_close(database)
            isDatabaseOpen = false
        }
    }
    
    private func dataFilePath() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.first?.appendingPathComponent("data.plist").path
        return url!
    }
    
    private func deleteDatabase() {
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: dataFilePath())
    }
    
    func checkIfDatabaseFileExists() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.first?.appendingPathComponent("data.plist")
        if let _ = try? url?.checkResourceIsReachable() {
            isDatabaseCreated = true
        }
    }
    
    func initDatabase() {
        // deleteDatabase()
        
        checkIfDatabaseFileExists()
        openDatabase()
        
        let createSubjectSQL = "CREATE TABLE IF NOT EXISTS SUBJECT " +
        "(SUBJECT_ID INTEGER PRIMARY KEY AUTOINCREMENT, DESCRIPTION TEXT NOT NULL, " +
            "COLOR TEXT NOT NULL, ACTIVE INTEGER DEFAULT 1);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        if (sqlite3_exec(database, createSubjectSQL, nil, nil, &errMsg) != SQLITE_OK) {
            closeDatabase()
            print("Failed to create table Subject")
            return
        }
        
        let createNoteSQL = "CREATE TABLE IF NOT EXISTS NOTE " +
        "(NOTE_ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT NOT NULL, DESCRIPTION TEXT NOT NULL, " +
        " DATETIME TEXT NOT NULL, LATITUDE REAL NOT NULL, LONGITUDE REAL NOT NULL, SUBJECT_ID INTEGER NOT NULL, " +
        " FOREIGN KEY (SUBJECT_ID) REFERENCES SUBJECT(SUBJECT_ID));"

        if (sqlite3_exec(database, createNoteSQL, nil, nil, &errMsg) != SQLITE_OK) {
            closeDatabase()
            print("Failed to create table Note")
            return
        }
        
        let createPicturesSQL = "CREATE TABLE IF NOT EXISTS PICTURE " +
            "(PICTURE_ID INTEGER PRIMARY KEY AUTOINCREMENT, NOTE_ID INTEGER NOT NULL, PICTURE TEXT NOT NULL, " +
        " FOREIGN KEY (NOTE_ID) REFERENCES NOTE(NOTE_ID));"
        
        if (sqlite3_exec(database, createPicturesSQL, nil, nil, &errMsg) != SQLITE_OK) {
            closeDatabase()
            print("Failed to create table Picture")
            return
        }
        
        if !isDatabaseCreated {
            addSubject(Subject("Personal", UIColor.blue))
            addSubject(Subject("Work", UIColor.orange))
            addSubject(Subject("College", UIColor.green))
        }
    }
    
    // MARK: Selects
    
    func selectSubjects() -> [Subject] {
        openDatabase()
        var subjects: [Subject] = []
        let query = "SELECT * FROM SUBJECT WHERE ACTIVE = 1 ORDER BY DESCRIPTION"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let subjectId = Int(sqlite3_column_int(statement, 0))
                let subject = String(cString:sqlite3_column_text(statement, 1))
                let color = sqlite3_column_text(statement, 2)
                let active = Int(sqlite3_column_int(statement, 3))
                let colorUI = UIColor.StringToUIColor(string: String(cString:color!))
                subjects.append(Subject(subjectId, subject, colorUI, active))
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Subject")
        }
        closeDatabase()
        return subjects
    }
    
    func selectSubjectById(_ subjectId: Int) -> Subject? {
        openDatabase()
        var subjectObj: Subject?
        let query = "SELECT * FROM SUBJECT WHERE SUBJECT_ID = \(subjectId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let subjectId = Int(sqlite3_column_int(statement, 0))
                let subject = String(cString:sqlite3_column_text(statement, 1))
                let color = sqlite3_column_text(statement, 2)
                let active = Int(sqlite3_column_int(statement, 3))
                let colorUI = UIColor.StringToUIColor(string: String(cString:color!))
                subjectObj = Subject(subjectId, subject, colorUI, active)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Subject BY id")
        }
        closeDatabase()
        return subjectObj
    }
    
    func selectNotesBySubject(_ subject: Subject, _ usingImagePath: Bool) -> [Note] {
        openDatabase()
        var notes: [Note] = []
        let query = "SELECT * FROM NOTE WHERE SUBJECT_ID = \(subject.subjectId) ORDER BY TITLE"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let noteId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString:sqlite3_column_text(statement, 1))
                let description = String(cString:sqlite3_column_text(statement, 2))
                let datetimeString = String(cString:sqlite3_column_text(statement, 3))
                let latitude = Double(sqlite3_column_double(statement, 4))
                let longitude = Double(sqlite3_column_double(statement, 5))
                let subjectId = Int(sqlite3_column_int(statement, 6))
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let subject = selectSubjectById(subjectId)
                let datetime = stringToDate(datetimeString)
                var pictures: [Picture] = []
                if usingImagePath {
                    pictures = selectPicturePathsByNoteId(noteId, false)
                } else {
                    pictures = selectPicturesByNoteId(noteId, false)
                }
                notes.append(Note(noteId, title, description, subject!, datetime, location, pictures))
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Note BY Subject")
        }
        closeDatabase()
        return notes
        
    }
    
    func selectNotes(_ usingImagePath: Bool) -> [Note] {
        openDatabase()
        var notes: [Note] = []
        let query = "SELECT NOTE_ID, TITLE, DESCRIPTION, DATETIME, LATITUDE, LONGITUDE, SUBJECT_ID FROM NOTE ORDER BY TITLE"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let noteId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString:sqlite3_column_text(statement, 1))
                let description = String(cString:sqlite3_column_text(statement, 2))
                let datetimeString = String(cString:sqlite3_column_text(statement, 3))
                let latitude = Double(sqlite3_column_double(statement, 4))
                let longitude = Double(sqlite3_column_double(statement, 5))
                let subjectId = Int(sqlite3_column_int(statement, 6))
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let subject = selectSubjectById(subjectId)
                let datetime = stringToDate(datetimeString)
                var pictures: [Picture] = []
                if usingImagePath {
                    pictures = selectPicturePathsByNoteId(noteId, false)
                } else {
                    pictures = selectPicturesByNoteId(noteId, false)
                }
                notes.append(Note(noteId, title, description, subject!, datetime, location, pictures))
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to return rows from table Note")
        }
        closeDatabase()
        return notes
    }
    
    func selectNotesByTitle(_ search: String, _ subject: Subject?) -> [Note] {
        openDatabase()
        var notes: [Note] = []
        var query = "SELECT * FROM NOTE "
        if subject == nil {
            query += "WHERE TITLE LIKE '%\(search)%' ORDER BY TITLE"
        } else {
            query += "WHERE SUBJECT_ID = \(subject!.subjectId) TITLE LIKE '%\(search)%' ORDER BY TITLE"
        }
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let noteId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString:sqlite3_column_text(statement, 1))
                let description = String(cString:sqlite3_column_text(statement, 2))
                let datetimeString = String(cString:sqlite3_column_text(statement, 3))
                let latitude = Double(sqlite3_column_double(statement, 4))
                let longitude = Double(sqlite3_column_double(statement, 5))
                let subjectId = Int(sqlite3_column_int(statement, 6))
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let subject = selectSubjectById(subjectId)
                let datetime = stringToDate(datetimeString)
                let pictures = selectPicturesByNoteId(noteId, false)
                
                notes.append(Note(noteId, title, description, subject!, datetime, location, pictures))
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to return rows from table Note searched by title")
        }
        closeDatabase()
        return notes
    }
    
    func selectNotesByKeyword(_ search: String, _ subject: Subject?) -> [Note] {
        openDatabase()
        var notes: [Note] = []
        var query = "SELECT * FROM NOTE "
        if subject == nil {
            query += "WHERE DESCRIPTION LIKE '%\(search)%' ORDER BY TITLE"
        } else {
            query += "WHERE SUBJECT_ID = \(subject!.subjectId) DESCRIPTION LIKE '%\(search)%' ORDER BY TITLE"
        }
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let noteId = Int(sqlite3_column_int(statement, 0))
                let title = String(cString:sqlite3_column_text(statement, 1))
                let description = String(cString:sqlite3_column_text(statement, 2))
                let datetimeString = String(cString:sqlite3_column_text(statement, 3))
                let latitude = Double(sqlite3_column_double(statement, 4))
                let longitude = Double(sqlite3_column_double(statement, 5))
                let subjectId = Int(sqlite3_column_int(statement, 6))
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let subject = selectSubjectById(subjectId)
                let datetime = stringToDate(datetimeString)
                let pictures = selectPicturesByNoteId(noteId, false)
                
                notes.append(Note(noteId, title, description, subject!, datetime, location, pictures))
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to return rows from table Note searched by keyword")
        }
        closeDatabase()
        return notes
    }
    
    private func selectNewestNoteId() -> Int {
        openDatabase()
        var noteId = -1
        let query = "SELECT NOTE_ID FROM NOTE ORDER BY NOTE_ID DESC LIMIT 1"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                noteId = Int(sqlite3_column_int(statement, 0))
                
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to return rows from table Note")
        }
        closeDatabase()
        return noteId
    }
    
    func selectPicturesByNoteId(_ noteId: Int, _ singleExecution: Bool = true) -> [Picture] {
        openDatabase()
        var pictures: [Picture] = []
        let query = "SELECT * FROM PICTURE WHERE NOTE_ID = \(noteId)"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let pictureId = Int(sqlite3_column_int(statement, 0))
                let noteId = Int(sqlite3_column_int(statement, 1))
                let strBase64 = String(cString: sqlite3_column_text(statement, 2))
                print("Retrieving image id \(pictureId) from noteId \(noteId) with size \(strBase64.count)")
                if (strBase64.isEmpty) {
                    print("Image could not be retrieved!")
                    continue
                }
                let dataDecoded:Data = Data(base64Encoded: strBase64)!
                let picture = UIImage(data: dataDecoded as Data)!
                pictures.append(Picture(pictureId, noteId, picture))
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Picture")
        }
        if singleExecution {
            closeDatabase()
        }
        return pictures
    }
    
    func selectPicturePathsByNoteId(_ noteId: Int, _ singleExecution: Bool = true) -> [Picture] {
        openDatabase()
        var pictures: [Picture] = []
        let query = "SELECT * FROM PICTURE WHERE NOTE_ID = \(noteId)"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let pictureId = Int(sqlite3_column_int(statement, 0))
                let noteId = Int(sqlite3_column_int(statement, 1))
                let path = String(cString: sqlite3_column_text(statement, 2))
                if (path.isEmpty) {
                    print("Image could not be retrieved!")
                    continue
                }
                pictures.append(Picture(pictureId, noteId, path))
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Picture")
        }
        if singleExecution {
            closeDatabase()
        }
        return pictures
    }

    // MARK: Inserts
    
    func addSubject(_ subject: Subject) {
        openDatabase()
        let colorText = UIColor.UIColorToString(color: subject.color)
        
        let insert = "INSERT INTO SUBJECT (DESCRIPTION, COLOR) " +
        "VALUES (?, ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, subject.subject, -1, nil)
            sqlite3_bind_text(statement, 2, colorText, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting subject")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func addNote(_ note: Note) {
        openDatabase()
        let insert = "INSERT INTO NOTE (TITLE, DESCRIPTION, DATETIME, LATITUDE, LONGITUDE, SUBJECT_ID) " +
        "VALUES (?, ?, ?, ?, ?, ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            
            let dateString = dateToString(note.dateTime)
            sqlite3_bind_text(statement, 1, note.title, -1, nil)
            sqlite3_bind_text(statement, 2, note.description, -1, nil)
            sqlite3_bind_text(statement, 3, dateString, -1, nil)
            sqlite3_bind_double(statement, 4, (note.location?.latitude)!)
            sqlite3_bind_double(statement, 5, (note.location?.longitude)!)
            sqlite3_bind_int(statement, 6, Int32(note.subject.subjectId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting note")
                closeDatabase()
                return
            } else {
                addPicturesToNewestNote(note.photos)
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func addPicturesToNewestNote(_ pictures: [Picture]) {
        let noteId = selectNewestNoteId()
        let insert = "INSERT INTO PICTURE (NOTE_ID, PICTURE) VALUES (\(noteId), ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            for p in pictures {
                if p.path.isEmpty {
                    let imageData = UIImageJPEGRepresentation(p.picture, 100.0)!
                    let strBase64 = imageData.base64EncodedString()
                    if (strBase64.isEmpty) {
                        print("Image could not be converted!")
                        continue
                    }
                    sqlite3_bind_text(statement, 1, strBase64, -1, nil)
                } else {
                    sqlite3_bind_text(statement, 1, p.path, -1, nil)
                }
                if sqlite3_step(statement) != SQLITE_DONE {
                    print("Error inserting picture")
                }
                sqlite3_reset(statement)
            }
            sqlite3_finalize(statement)
        } else {
            print("INSERT picture statement could not be prepared.")
        }
        closeDatabase()
    }
    
    func addPicture(_ noteId: Int, _ picture: UIImage) {
        openDatabase()
        let insert = "INSERT INTO PICTURE (NOTE_ID, PICTURE) VALUES (\(noteId), ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            let imageData = UIImageJPEGRepresentation(picture, 100.0)!
            let strBase64 = imageData.base64EncodedString()
            if (strBase64.isEmpty) {
                print("Image could not be converted!")
            }
            sqlite3_bind_text(statement, 1, strBase64, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting picture")
            }
            sqlite3_finalize(statement)
        } else {
            
            print("INSERT picture statement could not be prepared. \(sqlite3_errmsg(statement))")
        }
        closeDatabase()
    }
    
    func addPicturePath(_ noteId: Int, _ path: String) {
        openDatabase()
        let insert = "INSERT INTO PICTURE (NOTE_ID, PICTURE) VALUES (\(noteId), ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, path, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting picture")
            }
            sqlite3_finalize(statement)
        } else {
            
            print("INSERT picture statement could not be prepared. \(sqlite3_errmsg(statement))")
        }
        closeDatabase()
    }

    // MARK: Updates
    
    func updateSubject(_ subject: Subject) {
        openDatabase()
        let colorText = UIColor.UIColorToString(color: subject.color)
        
        let update = "UPDATE SUBJECT SET DESCRIPTION = ?, COLOR = ? " +
        "WHERE SUBJECT_ID = \(subject.subjectId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, subject.subject, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, colorText, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error updating subject")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func updateNote(_ note: Note) {
        openDatabase()
        let update = "UPDATE NOTE SET TITLE = ?, DESCRIPTION = ?, DATETIME = ?, LATITUDE = ?, LONGITUDE = ?, SUBJECT_ID = ? " +
        "WHERE NOTE_ID = \(note.noteId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
            
            let dateString = dateToString(note.dateTime)
            sqlite3_bind_text(statement, 1, note.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, note.description, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, dateString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_double(statement, 4, (note.location?.latitude)!)
            sqlite3_bind_double(statement, 5, (note.location?.longitude)!)
            sqlite3_bind_int(statement, 6, Int32(note.subject.subjectId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error updating note")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        } else {
            print("Database error: \(sqlite3_errmsg(database)!)")
        }
        if sqlite3_changes(database) > 0 {
            print("did update")
        } else {
            print("did NOT update")
        }
        closeDatabase()
    }
    
    // MARK: Deletes
    
    func deleteSubject(_ subject: Subject) {
        openDatabase()
        let delete = "UPDATE SUBJECT SET ACTIVE = 0 WHERE SUBJECT_ID = \(subject.subjectId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Subject row deleted")
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting subject")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func deleteNote(_ note: Note) {
        openDatabase()
        let delete = "DELETE FROM NOTE WHERE NOTE_ID = \(note.noteId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Note row deleted")
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting note")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func deletePicture(_ pictureId: Int) {
        openDatabase()
        let delete = "DELETE FROM PICTURE WHERE PICTURE_ID = \(pictureId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Picture row deleted")
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting picture by pictureId")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    func deletePicturesByNoteId(_ noteId: Int) {
        openDatabase()
        let delete = "DELETE FROM PICTURE WHERE NOTE_ID = \(noteId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Picture rows deleted")
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting pictures by noteId")
                closeDatabase()
                return
            }
            sqlite3_finalize(statement)
        }
        closeDatabase()
    }
    
    // MARK: Auxiliaries
    
    func getAddressFromGeocodeCoordinate(_ latitude: Double, _ longitude: Double, _ completion: @escaping (String?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            var address = ""
            if let street = placemark.thoroughfare {
                address += street
            }
            if let complement = placemark.subThoroughfare {
                address += address.isEmpty ? complement : " - \(complement)"
            }
            if let city = placemark.locality {
                address += address.isEmpty ? city : " - \(city)"
            }
            if let state = placemark.administrativeArea {
                address += address.isEmpty ? state : " - \(state)"
            }
            if let country = placemark.country {
                address += address.isEmpty ? country : " - \(country)"
            }
            if let postalCode = placemark.postalCode {
                address += address.isEmpty ? postalCode : " - \(postalCode)"
            }
            print("address: \(address)")
            completion(address, nil)
        }
    }
    
    func stringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("ERROR: Date to String conversion failed due to mismatched format.")
        }
        return date
    }
    func dateToString (_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
}

public extension UIColor {
    
    class func UIColorToString(color: UIColor) -> String {
        let components = color.cgColor.components
        return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
    
    class func StringToUIColor(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        
        let components = componentsString.components(separatedBy: ", ")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                       green: CGFloat((components[1] as NSString).floatValue),
                       blue: CGFloat((components[2] as NSString).floatValue),
                       alpha: CGFloat((components[3] as NSString).floatValue))
    }
    
}
