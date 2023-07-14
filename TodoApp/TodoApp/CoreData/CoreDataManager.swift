//
//  CoreDataManager.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 14.07.2023.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadItems() -> [TodoItem] {
        var todoItems = [TodoItem]()
        
        do {
            let items = try context.fetch(TodoItemForCoreData.fetchRequest())
            for item in items {
                todoItems.append(TodoItem(id: item.id ?? UUID().uuidString,
                                          text: item.text ?? "",
                                          importance: Importance(rawValue: item.importance ?? "basic") ?? .basic,
                                          deadline: item.deadline,
                                          isDone: item.done,
                                          creationDate: item.createdAt ?? Date(),
                                          modifiedDate: item.changedAt ?? Date()
                                         ))
            }
        } catch {
            print("Present row error: \(error)")
        }
        
        return todoItems
    }
    
    func insertItem(todoItem: TodoItem) {
        let newItem = TodoItemForCoreData(context: context)
        
        newItem.id = todoItem.id
        newItem.text = todoItem.text
        newItem.importance = todoItem.importance.rawValue
        newItem.deadline = todoItem.deadline
        newItem.done = todoItem.isDone
        newItem.createdAt = todoItem.creationDate
        newItem.changedAt = todoItem.modifiedDate
        
        do {
            try context.save()
        } catch {
            print("Insert item error: \(error)")
        }
    }
    
    func deleteItem(id: String) {
        do {
            guard let item = getItemFromId(id: id) else { return }
            
            context.delete(item)
            
            try context.save()
        } catch {
            print("Delete item error: \(error)")
        }
    }
    
    func replaceItemBy(newItem: TodoItem) {
        do {
            guard let item = getItemFromId(id: newItem.id) else { return }
        
            item.setValue(newItem.id, forKey: "id")
            item.setValue(newItem.text, forKey: "text")
            item.setValue(newItem.importance.rawValue, forKey: "importance")
            item.setValue(newItem.deadline, forKey: "deadline")
            item.setValue(newItem.isDone, forKey: "done")
            item.setValue(newItem.creationDate, forKey: "createdAt")
            item.setValue(newItem.modifiedDate, forKey: "changedAt")
            try context.save()
        } catch {
            print("Replace item error: \(error)")
        }
    }
    
    private func getItemFromId(id: String) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TodoItemForCoreData")
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            return try context.fetch(request).first
        } catch {
            print("Cannot take item from id: \(error)")
        }
        
        return nil
    }
 }
