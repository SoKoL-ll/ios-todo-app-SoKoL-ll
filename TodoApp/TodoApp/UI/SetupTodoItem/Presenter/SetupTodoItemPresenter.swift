//
//  SetupTodoItemPresenter.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation

class SetupTodoItemPresenter: SetupTodoItemPresenterProtocol {
    private var todoItemText: String
    private var todoItemImportance: Importance
    private var todoItemId: String
    private var todoItemDeadline: Date?
    private var todoItemIsDone: Bool
    private var todoItemCreationDate: Date
    private var todoItemModifiedDate: Date?
    private let fileCache: FileCache
    
    init() {
        todoItemId = ""
        todoItemText = ""
        todoItemImportance = .common
        todoItemIsDone = false
        todoItemCreationDate = Date()
        fileCache = FileCache()
    }
    
    func dateDidChanged(date: Date) {
        todoItemDeadline = date
    }
    
    func updateDescriptionField(text: String) {
        todoItemText = text
    }
    
    func updateImportance(importance: Importance) {
        todoItemImportance = importance
    }
    
    func saveTodoItem() {
        fileCache.appendNewItem(item: TodoItem(id: todoItemId,
                                               text: todoItemText,
                                               importance: todoItemImportance,
                                               deadline: todoItemDeadline,
                                               isDone: todoItemIsDone,
                                               creationDate: todoItemCreationDate,
                                               modifiedDate: todoItemModifiedDate))
        
        fileCache.saveTodoItemsToJsonFile(file: "todoItem.json")
    }
    
    func deleteTodoItem() {
        let _ = fileCache.removeItem(id: todoItemId)
    }
}
