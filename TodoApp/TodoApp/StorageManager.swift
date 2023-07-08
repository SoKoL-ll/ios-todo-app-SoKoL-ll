//
//  StorageManager.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 08.07.2023.
//

import Foundation
import TodoItemPackage
import UIKit

//Not working now
class StorageManager {
    private let fileCache: FileCache
    private let networkService: NetworkService
    private var revision: Int = 0
    private let queue = DispatchQueue(label: "todo.list.queue", qos: .userInitiated)

    init(fileCache: FileCache, networkService: NetworkService) {
        self.fileCache = fileCache
        self.networkService = networkService
    }
    
    func save(id: String, todoItem: TodoItemProps, isNew: Bool, complition: @escaping () -> ()) {
        queue.async {
            let networkTodoItem = OperationTodoItemNetworkModel(element: TodoItemNetworkModel(id: id,
                                                                                        text: todoItem.text,
                                                                                        importance: todoItem.importance,
                                                                                              deadline: todoItem.deadline.map { Int($0.timeIntervalSince1970) },
                                                                                        done: false,
                                                                                        created_at: Int(Date().timeIntervalSince1970),
                                                                                        changed_at: Int(Date().timeIntervalSince1970),
                                                                                        last_updated_by: UIDevice.current.identifierForVendor?.uuidString ?? "0"),
                                                          revision: nil)
            
            guard let data = try? JSONEncoder().encode(networkTodoItem) else { return }
            
            if isNew {
                self.networkService.addTodoItem(revision: self.revision, data: data) { result in
                    switch result {
                    case .success(let response):
                        var setDeadline: Date? = nil
                        if let deadline = response.element.deadline {
                            setDeadline = Date(timeIntervalSince1970: TimeInterval(deadline))
                        }
                    
                        self.fileCache.appendNewItem(item: TodoItem(id: response.element.id,
                                                                    text: response.element.text,
                                                                    importance: response.element.importance,
                                                                    deadline: setDeadline,
                                                                    isDone: response.element.done,
                                                                    creationDate: Date(timeIntervalSince1970: TimeInterval(response.element.created_at)),
                                                                    modifiedDate: Date(timeIntervalSince1970: TimeInterval(response.element.changed_at))))
                        self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
                    case .failure(let error):
                        SyncTodoItems.isDirty = true
                        print("Error occured \(error)")
                    }
                }
            } else {
                self.networkService.putTodoItem(id: id, revision: self.revision, data: data) { result in
                    switch result {
                    case .success(let response):
                        var setDeadline: Date? = nil
                        if response.element.deadline != nil {
                            setDeadline = Date(timeIntervalSince1970: TimeInterval(response.element.deadline ?? 0))
                        }
                        self.fileCache.appendNewItem(item: TodoItem(id: response.element.id,
                                                                    text: response.element.text,
                                                                    importance: response.element.importance,
                                                                    deadline: setDeadline,
                                                                    isDone: response.element.done,
                                                                    creationDate: Date(timeIntervalSince1970: TimeInterval(response.element.created_at)),
                                                                    modifiedDate: Date(timeIntervalSince1970: TimeInterval(response.element.changed_at))))
                        self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
                    case .failure(let error):
                        SyncTodoItems.isDirty = true
                        print("Error occured \(error)")
                    }
                }
            }
            complition()
        }
    }
    
    func get(complition: @escaping () -> ()) {
        queue.async {
            self.networkService.getAllTodoItems { result in
                switch result {
                case.success(let response):
                    self.revision = response.revision ?? 0
                    self.fileCache.todoItems = [:]
                    guard let todoItems = response.list else { return }
                    for item in todoItems {
//                        self.counterId = max(self.counterId, Int(item.id) ?? 0)
                        var setDeadline: Date? = nil
                        if item.deadline != nil {
                            setDeadline = Date(timeIntervalSince1970: TimeInterval(item.deadline ?? 0))
                        }
                        self.fileCache.appendNewItem(item: TodoItem(id: item.id,
                                                                    text: item.text,
                                                                    importance: item.importance,
                                                                    deadline: setDeadline,
                                                                    isDone: item.done,
                                                                    creationDate: Date(),
                                                                    modifiedDate: nil)
                        )
                    }
                    self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
                    complition()
                case .failure(let error):
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    func delete(id: String, complition: @escaping () -> ()) {
        let _ = self.fileCache.removeItem(id: id)
        queue.async {
            self.networkService.deleteTodoItem(revision: self.revision, id: id) { result in
                switch result {
                case.success(let response):
                    self.revision = response.revision ?? 0
                case .failure(let error):
                    print("Error occured \(error)")
                }
            }
            complition()
        }
    }
    
    func put(id: String, complition: @escaping () -> ()) {
        guard let toggleTodoItem = fileCache.todoItems[id] else { return }
        
        DispatchQueue.global().async {
            let networkTodoItem = OperationTodoItemNetworkModel(element: TodoItemNetworkModel(id: toggleTodoItem.id,
                                                                                              text: toggleTodoItem.text,
                                                                                        importance: toggleTodoItem.importance,
                                                                                              deadline: toggleTodoItem.deadline.map {Int($0.timeIntervalSince1970)},
                                                                                              done: toggleTodoItem.isDone,
                                                                                        created_at: Int(Date().timeIntervalSince1970),
                                                                                        changed_at: Int(Date().timeIntervalSince1970),
                                                                                        last_updated_by: UIDevice.current.identifierForVendor?.uuidString ?? "0"),
                                                          revision: nil)
            
            guard let data = try? JSONEncoder().encode(networkTodoItem) else { return }
            self.networkService.putTodoItem(id: toggleTodoItem.id, revision: self.revision, data: data) { result in
                switch result {
                case .success(let response):
                    self.revision = response.revision ?? 0
                    var setDeadline: Date? = nil
                    if response.element.deadline != nil {
                        setDeadline = Date(timeIntervalSince1970: TimeInterval(response.element.deadline ?? 0))
                    }
                    self.fileCache.appendNewItem(item: TodoItem(id: response.element.id,
                                                                text: response.element.text,
                                                                importance: response.element.importance,
                                                                deadline: setDeadline,
                                                                isDone: response.element.done,
                                                                creationDate: Date(timeIntervalSince1970: TimeInterval(response.element.created_at)),
                                                                modifiedDate: Date(timeIntervalSince1970: TimeInterval(response.element.changed_at))))
                    self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
                    complition()
                case .failure(let error):
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    func getCellFromCache(id: String) -> TodoItem? {
        fileCache.todoItems[id]
    }
    
    func getFromCache() -> [TodoItemCellProps]{
        var todoItemsCell = [TodoItemCellProps]()
        var counter = 0
        for item in fileCache.todoItems {
            todoItemsCell.append(TodoItemCellProps(deadline: item.value.deadline?.toString(),
                                               text: item.value.text,
                                               checkButtonProps: TodoItemCellProps.CheckButtonProps(isDone: item.value.isDone, id: counter, importance: item.value.importance,
                                                                                                    onToggle: nil),
                                               id: item.value.id, openCell: nil, deleteCell: nil))
            
        }
        
        return todoItemsCell
    }
    
    func patch(complition: @escaping () -> ()) {
        queue.async {
            var listOfItems: [TodoItemNetworkModel] = []
            
            for item in self.fileCache.todoItems {
                listOfItems.append(TodoItemNetworkModel(id: item.value.id,
                                                        text: item.value.text,
                                                        importance: item.value.importance,
                                                        deadline: item.value.deadline.map { Int($0.timeIntervalSince1970) },
                                                        done: item.value.isDone,
                                                        created_at: Int(item.value.creationDate.timeIntervalSince1970),
                                                        changed_at: Int(item.value.modifiedDate!.timeIntervalSince1970),
                                                        last_updated_by: UIDevice.current.identifierForVendor?.uuidString ?? "0"))
            }
            let networkItem = TodoItemsNetworkModel(status: nil, list: listOfItems, revision: self.revision)
            
            guard let data = try? JSONEncoder().encode(networkItem) else { return }
            
            self.networkService.patchTodoItems(revision: self.revision, data: data) { result in
                switch result {
                case .success(let response):
                    self.revision = response.revision ?? 0
                    guard let todoItems = response.list else { return }
                    for item in todoItems {
                        var setDeadline: Date? = nil
                        if item.deadline != nil {
                            setDeadline = Date(timeIntervalSince1970: TimeInterval(item.deadline ?? 0))
                        }
                        self.fileCache.appendNewItem(item: TodoItem(id: item.id,
                                                                    text: item.text,
                                                                    importance: item.importance,
                                                                    deadline: setDeadline,
                                                                    isDone: item.done,
                                                                    creationDate: Date(),
                                                                    modifiedDate: nil)
                        )
                    }
                case .failure(let error):
                    print("Error occured \(error)")
                }
                complition()
            }
        }
    }
}
