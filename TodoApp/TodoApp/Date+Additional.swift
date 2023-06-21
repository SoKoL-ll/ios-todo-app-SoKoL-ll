//
//  Date+Additional.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 17.06.2023.
//

import Foundation

extension Date {
    enum DateFormat: String {
        case simpleFormat = "dd.MM.yyyy"
        var format: String {
            return self.rawValue
        }
    }
    
    static func toDate(from string: String, with format: DateFormat = .simpleFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.format

        return dateFormatter.date(from: string)
    }
    
    func toString(with format: DateFormat = .simpleFormat) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        var result = format.format
        zip(["dd", "MM", "yyyy", "HH", "mm", "ss"], [components.day, components.month, components.year, components.hour, components.minute, components.second]).forEach { format, dateComponents in
            result = result.replacingOccurrences(of: format, with: "\(dateComponents ?? 0)")
        }
        
        return result
    }
}
