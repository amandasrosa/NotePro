//
//  DatabaseController.swift
//  NotePro
//
//  Created by Amanda Rosa on 2018-04-02.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import CoreLocation

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

class DatabaseController: NSObject {

    var database:OpaquePointer? = nil
    
    func openDatabase() {
        if (sqlite3_open(dataFilePath(), &database) != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
    }
    
    func initDatabase() {
        openDatabase()
        let createSubjectSQL = "CREATE TABLE IF NOT EXISTS SUBJECT " +
        "(SUBJECT_ID INTEGER PRIMARY KEY AUTOINCREMENT, DESCRIPTION TEXT NOT NULL, " +
            "COLOR TEXT NOT NULL, ACTIVE INTEGER DEFAULT 1);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        if (sqlite3_exec(database, createSubjectSQL, nil, nil, &errMsg) != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table Subject")
            return
        }
        
        let createNoteSQL = "CREATE TABLE IF NOT EXISTS NOTE " +
        "(NOTE_ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT NOT NULL, DESCRIPTION TEXT NOT NULL, " +
        " DATETIME TEXT NOT NULL, LATITUDE REAL NOT NULL, LONGITUDE REAL NOT NULL, SUBJECT_ID INTEGER NOT NULL, " +
        " FOREIGN KEY (SUBJECT_ID) REFERENCES SUBJECT(SUBJECT_ID));"

        if (sqlite3_exec(database, createNoteSQL, nil, nil, &errMsg) != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table Note")
            return
        }
        
        let createPicturesSQL = "CREATE TABLE IF NOT EXISTS PICTURE " +
            "(PICTURE_ID INTEGER PRIMARY KEY AUTOINCREMENT, NOTE_ID INTEGER NOT NULL, PICTURE BLOB NOT NULL, " +
        " FOREIGN KEY (NOTE_ID) REFERENCES NOTE(NOTE_ID));"
        
        if (sqlite3_exec(database, createPicturesSQL, nil, nil, &errMsg) != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table Picture")
            return
        }
    }
    
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
        sqlite3_close(database)
        return subjects
        
    }
    
    func selectNotesBySubject(_ subject: Subject) -> [Note] {
        openDatabase()
        var notes: [Note] = []
        let query = "SELECT * FROM NOTE WHERE SUBJECT_ID = \(subject.subjectId) ORDER BY TITLE"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            //
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
                
                getAddressFromGeocodeCoordinate(latitude: latitude, longitude: longitude) { placemark, error in
                    guard let placemark = placemark, error == nil else { return }
                    DispatchQueue.main.async {
                        
                        let address = " \(placemark.thoroughfare) \(placemark.subThoroughfare) \(placemark.locality) \(placemark.administrativeArea) \(placemark.postalCode) \(placemark.country)"
                        notes.append(Note(noteId, title, description, subject!, datetime, location, address))
                    }
                }
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Note BY Subject")
        }
        sqlite3_close(database)
        return notes
        
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
        sqlite3_close(database)
        return subjectObj
    }
    
    func selectNotes() -> [Note] {
        openDatabase()
        var notes: [Note] = []
        let query = "SELECT * FROM NOTE ORDER BY TITLE"
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
                
                getAddressFromGeocodeCoordinate(latitude: latitude, longitude: longitude) { placemark, error in
                    guard let placemark = placemark, error == nil else { return }
                    DispatchQueue.main.async {
                
                        let address = " \(placemark.thoroughfare) \(placemark.subThoroughfare) \(placemark.locality) \(placemark.administrativeArea) \(placemark.postalCode) \(placemark.country)"
                        notes.append(Note(noteId, title, description, subject!, datetime, location, address))
                    }
                }
            }
            sqlite3_finalize(statement)
            
        } else {
            print("Failed to return rows from table Note")
        }
        sqlite3_close(database)
        return notes
    }
    
    //Araceli
    func selectPicturesByNote(_ note: Note) -> [UIImage] {
        openDatabase()
        var pictures: [UIImage] = []
        let query = "SELECT * FROM PICTURES WHERE NOTE_ID = \(note.noteId)"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let pictureId = Int(sqlite3_column_int(statement, 0))
                let noteId = Int(sqlite3_column_int(statement, 1))
                let picture = sqlite3_column_blob(statement, 2)
                //pictures.append()
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to return rows from table Subject")
        }
        sqlite3_close(database)
        return pictures
        
    }

    func dataFilePath() -> String {
        let urls = FileManager.default.urls(for:
            .documentDirectory, in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("data.plist").path
        return url!
    }

    func addSubject(_ subject: Subject) {
        openDatabase()
        let colorText = UIColor.UIColorToString(color: subject.color)
        
        let insert = "INSERT INTO SUBJECT (DESCRIPTION, COLOR) " +
        "VALUES (?, ?);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, subject.subject, -1, nil)
            sqlite3_bind_text(statement, 2, colorText, -1, nil)
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error adding subject")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
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
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error adding note")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    //Araceli
    func addPictures(_ pictures: [UIImage], _ note: Note ) {
        openDatabase()
        let insert = "INSERT INTO PICTURE (NOTE_ID, PICTURE) " +
            "VALUES (?, ?);"
        var statement:OpaquePointer? = nil
        for pic in pictures {
            if sqlite3_prepare_v2(database, insert, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(note.noteId))
                //Converter UIImage pra Blob
                //sqlite3_bind_blob(statement, 2, pic, -1, nil)
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error adding note")
                sqlite3_close(database)
                return
            }
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    func updateNote(_ note: Note) {
        openDatabase()
        let update = "UPDATE NOTE SET TITLE = ?, DESCRIPTION = ?, DATETIME = ?, LATITUDE = ?, LONGITUDE = ?, SUBJECT_ID = ?) " +
        "WHERE NOTE_ID = \(note.noteId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
            
            let dateString = dateToString(note.dateTime)
            sqlite3_bind_text(statement, 1, note.title, -1, nil)
            sqlite3_bind_text(statement, 2, note.description, -1, nil)
            sqlite3_bind_text(statement, 3, dateString, -1, nil)
            sqlite3_bind_double(statement, 4, (note.location?.latitude)!)
            sqlite3_bind_double(statement, 5, (note.location?.longitude)!)
            sqlite3_bind_int(statement, 6, Int32(note.subject.subjectId))
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error updating note")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    func updateSubject(_ subject: Subject) {
        openDatabase()
        let colorText = UIColor.UIColorToString(color: subject.color)
        
        let update = "UPDATE SUBJECT SET DESCRIPTION = ?, COLOR = ? " +
        "WHERE SUBJECT_ID = \(subject.subjectId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, subject.subject, -1, nil)
            sqlite3_bind_text(statement, 2, colorText, -1, nil)
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error adding subject")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    func deleteNote(_ note: Note) {
        openDatabase()
        let delete = "DELETE FROM NOTE WHERE NOTE_ID = \(note.noteId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Note row deleted")
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error deleting note")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    func deleteSubject(_ subject: Subject) {
        openDatabase()
        let delete = "UPDATE SUBJECT SET ACTIVE = 0 WHERE SUBJECT_ID = \(subject.subjectId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Subject row deleted")
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error deleting subject")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    //Araceli
    func deletePictures(_ pictureId: Int)
    {
        openDatabase()
        let delete = "DELETE FROM PICTURE WHERE PICTURE_ID = \(pictureId);"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &statement, nil) == SQLITE_OK {
            print("Picture row deleted")
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error deleting picture")
            sqlite3_close(database)
            return
        }
        sqlite3_finalize(statement)
        sqlite3_close(database)
    }
    
    func getAddressFromGeocodeCoordinate(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
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
