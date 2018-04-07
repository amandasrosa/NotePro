//
//  DateUtil.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import Foundation

class DateUtil {
    static let dateFormatter = DateFormatter()
    
    static func convertStringToDate(_ stringDate: String) -> Date? {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.date(from: stringDate)
    }
    
    static func convertStringToDate(_ stringDate: String, _ format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: stringDate)
    }
    
    static func convertDateToString(_ date: Date?) -> String {
        if date == nil {
            return ""
        }
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date!)
    }
    
    static func convertDateToString(_ date: Date?, _ format: String) -> String {
        if date == nil {
            return ""
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date!)
    }
    
    static func convertDateToString(_ date: Date?, _ dateFormat: DateFormatter.Style, _ timeFormat: DateFormatter.Style) -> String {
        if date == nil {
            return ""
        }
        dateFormatter.dateStyle = dateFormat
        dateFormatter.timeStyle = timeFormat
        return dateFormatter.string(from: date!)
    }
}
