//
//  FileCache.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 14.07.2023.
//

import Foundation

public class FileCache {
    let headOfCSVFile = "id,text,importance,deadline,isDone,creationDate,modifiedDate\n"
    var todoItems = [String: TodoItem]()
    private let coreDataManager = CoreDataManager()
    
    
    init() {
        SQLIteDatabase.sharedInstance.createTable()
    }
    
    func appendNewItem(item: TodoItem) {
        if todoItems[item.id] != nil {
            replaceSQLiteDatabase(item: item)
            replaceCoreData(item: item)
        } else {
            insertItemToCoreData(item: item)
            insertSQLiteDatabase(item: item)
        }
        
        todoItems[item.id] = item
    }
    
    @discardableResult
    func removeItem(id: String) -> TodoItem? {
        deleteSQLiteDatabase(itemId: id)
        deleteItemFromCoreData(id: id)
        return todoItems.removeValue(forKey: id)
        
    }
    
    private func replaceSQLiteDatabase(item: TodoItem) {
        SQLiteManager.replaceRow(item)
    }
    
    private func replaceCoreData(item: TodoItem) {
        coreDataManager.replaceItemBy(newItem: item)
    }
    
    private func insertSQLiteDatabase(item: TodoItem) {
        SQLiteManager.insertRow(item)
    }
    
    private func insertItemToCoreData(item: TodoItem) {
        coreDataManager.insertItem(todoItem: item)
    }
    
    private func deleteSQLiteDatabase(itemId: String) {
        SQLiteManager.deleteRows(itemId: itemId)
    }
    
    private func deleteItemFromCoreData(id: String) {
        coreDataManager.deleteItem(id: id)
    }
    
    func loadTodoItems() {
        if let todoItems = SQLiteManager.presentRows() {
            for item in todoItems {
                self.todoItems[item.id] = item
            }
        }
    }
    
    func loadTodoItemsFromCoreData() {
        let todoItems = coreDataManager.loadItems()
        for item in todoItems {
            coreDataManager.insertItem(todoItem: item)
            self.todoItems[item.id] = item
        }
    }
    
    func saveTodoItemsToCSVFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!.appending(path: file)
            var items = headOfCSVFile
            
            for todoItem in todoItems {
                items += "\(todoItem.value.csv)\n"
            }
            
            try items.write(to: pathForFile, atomically: true, encoding: .utf8)
            
        } catch {
            print("Error when saving tasks to a CSV file \(error)")
        }
    }
    
    func loadTodoItemsFromCSVFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: file)
            let csv = try String(contentsOf: pathForFile, encoding: .utf8)
            
            let parsedCSV: [String] = csv.components(separatedBy: "\n")
            
            for pos in 1..<parsedCSV.count {
                if let item = TodoItem.parse(csv: parsedCSV[pos]) {
                    todoItems[item.id] = item
                }
            }
            
        } catch {
            print("Error when loading tasks from a file \(error)")
        }
    }
}
