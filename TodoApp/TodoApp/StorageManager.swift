//
//  StorageManager.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 08.07.2023.
//

import Foundation
import UIKit

class StorageManager {
    private let fileCache: FileCache
    private var revision: Int = 0
    private let queue = DispatchQueue(label: "todo.list.queue", qos: .userInitiated)
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
    }
    
    func save(id: String, todoItem: TodoItemProps, isNew: Bool, complition: @escaping () -> ()) {
        self.fileCache.appendNewItem(item: TodoItem(id: id,
                                                    text: todoItem.text,
                                                    importance: todoItem.importance,
                                                    deadline: todoItem.deadline,
                                                    isDone: todoItem.isDone,
                                                    creationDate: todoItem.createdDate,
                                                    modifiedDate: Date()
                                                   ))
        complition()
    }
    
    func get(complition: @escaping () -> ()) {
        self.fileCache.loadTodoItems()
        complition()
    }
    
    func delete(id: String, complition: @escaping () -> ()) {
        let _ = self.fileCache.removeItem(id: id)
        complition()
    }
    
    func put(id: String, complition: @escaping () -> ()) {
        guard fileCache.todoItems[id] != nil else { return }
    }
    
    func getCellFromCache(id: String) -> TodoItem? {
        fileCache.todoItems[id]
    }
    
    func changeToggle(id: String) {
        guard let item = fileCache.todoItems[id] else { return }
        fileCache.appendNewItem(item: TodoItem(id: item.id,
                                               text: item.text,
                                               importance: item.importance,
                                               deadline: item.deadline,
                                               isDone: !item.isDone,
                                               creationDate: item.creationDate,
                                               modifiedDate: item.modifiedDate
                                              ))
        put(id: id){}
    }
    
    func getItemFromCache(id: String) -> TodoItemProps? {
        guard let todoItem = fileCache.todoItems[id] else { return nil }
        
        return TodoItemProps(deadline: todoItem.deadline,
                             text: todoItem.text,
                             importance: todoItem.importance,
                             createdDate: todoItem.creationDate,
                             isDone: todoItem.isDone,
                             isDataPickerOpen: false,
                             isSwitcherState: false,
                             didOpenDatapiker: nil,
                             textDidChange: nil,
                             switchChange: nil,
                             setNewDate: nil,
                             cancel: nil,
                             saveTodoItem: nil,
                             updateDate: nil,
                             updateImportance: nil,
                             deleteItem: nil
        )
    }
    
    func getFromCache() -> [TodoItemCellProps]{
        var todoItemsCell = [TodoItemCellProps]()
        let todoItems = fileCache.todoItems.sorted { $0.value.creationDate > $1.value.creationDate }
        for item in todoItems {
            todoItemsCell.append(TodoItemCellProps(deadline: item.value.deadline?.toString(),
                                               text: item.value.text,
                                               checkButtonProps: TodoItemCellProps.CheckButtonProps(isDone: item.value.isDone, importance: item.value.importance,
                                                                                                    onToggle: nil),
                                               id: item.value.id, openCell: nil, deleteCell: nil))
            
        }

        return todoItemsCell
    }
}
