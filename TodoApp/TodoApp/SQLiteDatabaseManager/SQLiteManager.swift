//
//  SQLiteImpl.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 13.07.2023.
//

import Foundation
import SQLite
import SQLite3

class SQLiteManager {
    static var table = Table("todoItems")
    
    static let id = Expression<String>("id")
    static let text = Expression<String>("text")
    static let importance = Expression<String>("importance")
    static let deadline = Expression<Int?>("deadline")
    static let done = Expression<Bool>("done")
    static let created_at = Expression<Int>("created_at")
    static let changed_at = Expression<Int>("changed_at")
    
    static func createTable() {
        guard let database = SQLIteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return
        }
        
        do {
            try database.run(table.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(importance)
                table.column(deadline)
                table.column(done)
                table.column(created_at)
                table.column(changed_at)
            })
        } catch {
            print("Table already exists: \(error)")
        }
    }
    
    @discardableResult
    static func insertRow(_ todoItemValue: TodoItem) -> Bool? {
        guard let database = SQLIteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return nil
        }
        
        do {
            try database.run(table.insert(id <- todoItemValue.id,
                                          text <- todoItemValue.text,
                                          importance <- todoItemValue.importance.rawValue,
                                          deadline <- todoItemValue.deadline.map { Int($0.timeIntervalSince1970) },
                                          done <- todoItemValue.isDone,
                                          created_at <- Int(todoItemValue.creationDate.timeIntervalSince1970),
                                          changed_at <- Int(todoItemValue.modifiedDate.timeIntervalSince1970)
                                         ))
            return true
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Insert row failed: \(message), in \(String(describing:statement))")
            
            return false
        } catch let error {
            print("Insertion failed: \(error)")
            
            return false
        }
    }
    
    @discardableResult
    static func replaceRow(_ todoItemValue: TodoItem) -> Bool? {
        guard let database = SQLIteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return nil
        }
        
        let item = table.filter(id == todoItemValue.id).limit(1)
        
        do {
            if try database.run(item.update(id <- todoItemValue.id,
                                            text <- todoItemValue.text,
                                            importance <- todoItemValue.importance.rawValue,
                                            deadline <- todoItemValue.deadline.map { Int($0.timeIntervalSince1970) },
                                            done <- todoItemValue.isDone,
                                            created_at <- Int(todoItemValue.creationDate.timeIntervalSince1970),
                                            changed_at <- Int(todoItemValue.modifiedDate.timeIntervalSince1970)
                                           )) > 0 {
                print("Replace todo item")
                return true
            } else {
                print("Could not update todo item: item not found")
                return false
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Replace row failed: \(message), in \(String(describing: statement))")
            return false
            
        } catch let error {
            print("Replacing failed: \(error)")
            return false
        }
    }
    
    static func deleteRows(itemId: String) {
        guard let database = SQLIteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return
        }
        
        do {
            let todoItem = table.filter(id == itemId).limit(1)
            try database.run(todoItem.delete())
        } catch {
            print("Delete row error: \(error)")
        }
    }
    
    static func presentRows() -> [TodoItem]? {
        guard let database = SQLIteDatabase.sharedInstance.database else {
            print("Datastore connection error")
            return nil
        }
        
        var todoItems = [TodoItem]()
        
        table = table.order(created_at.desc)
        
        do {
            for item in try database.prepare(table) {
                var setDeadline: Date? = nil
                
                if item[deadline] != nil {
                    setDeadline = Date(timeIntervalSince1970: TimeInterval(item[deadline] ?? 0))
                }
                
                let todoItem = TodoItem(id: item[id],
                                        text: item[text],
                                        importance: Importance(rawValue: item[importance]) ?? .basic,
                                        deadline: setDeadline,
                                        isDone: item[done],
                                        creationDate: Date(timeIntervalSince1970: TimeInterval(item[created_at])),
                                        modifiedDate: Date(timeIntervalSince1970: TimeInterval(item[changed_at]))
                )
                
                todoItems.append(todoItem)
            }
        } catch {
            print("Present row error: \(error)")
        }
        
        return todoItems
    }
}
