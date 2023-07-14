//
//  SQLiteDatabase.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 13.07.2023.
//

import Foundation
import SQLite

class SQLIteDatabase {
    static let sharedInstance = SQLIteDatabase()
    var database: Connection?
    
    private init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let fileUrl = documentDirectory.appendingPathComponent("todoItems").appendingPathExtension("sqlite3")
            
            database = try Connection(fileUrl.path)
        } catch {
            print("Creating connection to database error: \(error)")
        }
    }
    
    func createTable() {
        SQLiteManager.createTable()
    }
}
