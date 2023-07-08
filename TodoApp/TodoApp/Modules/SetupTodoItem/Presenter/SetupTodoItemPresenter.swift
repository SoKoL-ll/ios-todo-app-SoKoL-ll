//
//  SetupTodoItemPresenter.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import TodoItemPackage
import UIKit

protocol SetupTodoItemDelegate {
    func closeScreen()
}

class SetupTodoItemPresenter: SetupTodoItemPresenterProtocol {
    private var render: (SetupTodoItemRendering & UIViewController)?
    private let fileCache: FileCache
    private let networkService: NetworkService
    private var todoItem: TodoItemProps?
    private var id: String?
    private var delegate: SetupTodoItemDelegate?
    private var revision: Int
    private var isNew = false
    
    init(fileCache: FileCache, networkService: NetworkService, sceneDelegate: SetupTodoItemDelegate, revision: Int) {
        self.fileCache = fileCache
        self.delegate = sceneDelegate
        self.networkService = networkService
        self.revision = revision
    }
    
    func build() {
        render = SetupTodoItemViewController()
    }
    
    func setupWithTodoItem(id: String, revision: Int) {
        self.id = id
        self.revision = revision
        self.isNew = false
        let todoItem = fileCache.todoItems[id]
        self.todoItem = TodoItemProps(
            deadline: todoItem?.deadline,
            text: todoItem?.text ?? "",
            importance: todoItem?.importance ?? .basic,
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
            deleteItem: nil)
        
        if let _ = self.todoItem?.deadline {
            self.todoItem?.isSwitcherState = true
        }
    }
    
    func setupNewTodoItem(id: String, revision: Int) {
        self.id = id
        self.revision = revision
        self.isNew = true
        let todoItem = TodoItem(text: id, importance: .basic, isDone: false, creationDate: Date())
        self.todoItem = TodoItemProps(text: "",
                                      importance: todoItem.importance,
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
                                      deleteItem: nil)
    }
    
    func open() -> UIViewController {
        render?.render(props: buildProps())
        
        return render ?? UIViewController()
    }
    
    private func buildProps() -> TodoItemProps {
        TodoItemProps(deadline: todoItem?.deadline,
                      text: todoItem?.text ?? "",
                      importance: todoItem?.importance ?? .basic,
                      isDataPickerOpen: todoItem?.isDataPickerOpen ?? false,
                      isSwitcherState: todoItem?.isSwitcherState ?? false,
                      didOpenDatapiker: { [weak self] in
                          guard let self else { return }
                          guard var todoItem = self.todoItem else { return }
                          todoItem.isDataPickerOpen = !todoItem.isDataPickerOpen
                          self.todoItem = todoItem
                          self.rerender()
                      },
                      textDidChange: { [weak self] text in
                          guard let self else { return }
                          self.todoItem?.text = text
                      },
                      switchChange: { [weak self] in
                          guard let self else { return }
                          guard var todoItem = self.todoItem else { return }
                          todoItem.isSwitcherState = !todoItem.isSwitcherState
                          if todoItem.deadline == nil {
                              todoItem.deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                          } else {
                              todoItem.deadline = nil
                          }
                          self.todoItem = todoItem
                          self.rerender()
                      },
                      setNewDate: nil,
                      cancel: { [weak self] in
                          self?.delegate?.closeScreen()
                      },
                      saveTodoItem: saveTodoItem(),
                      updateDate: { [weak self] date in
                          guard let self else { return }
                          self.todoItem?.deadline = date
                          self.rerender()
                      },
                      updateImportance: { [weak self] importance in
                          guard let self else { return }
                          self.todoItem?.importance = importance
                      },
                      deleteItem: deleteItem(id ?? ""))
    }
    
    func setNewDate(_ date: Date) -> (() -> ()) {
        return { [weak self, date] in
            guard let self else { return }
            
            self.todoItem?.deadline = date
            self.rerender()
        }
    }
    
    func deleteItem(_ id: String) -> (() -> ()) {
        return { [weak self, id] in
            guard let self else { return }
            
            let _ = self.fileCache.removeItem(id: id)
            self.delegate?.closeScreen()
        }
    }
    
    func saveTodoItem() -> (() -> ()) {
        return { [weak self] in
            guard let self else { return }
            guard let todoItem = self.todoItem else { return }
            self.fileCache.appendNewItem(item: TodoItem(id: self.id ?? "0",
                                                        text: todoItem.text,
                                                        importance: todoItem.importance,
                                                        deadline: todoItem.deadline,
                                                        isDone: false,
                                                        creationDate: Date(),
                                                        modifiedDate: Date()))
            DispatchQueue.global().sync {
                let networkTodoItem = OperationTodoItemNetworkModel(element: TodoItemNetworkModel(id: self.id ?? "0",
                                                                                            text: todoItem.text,
                                                                                            importance: todoItem.importance,
                                                                                                  deadline: todoItem.deadline.map { Int($0.timeIntervalSince1970) },
                                                                                            done: false,
                                                                                            created_at: Int(Date().timeIntervalSince1970),
                                                                                            changed_at: Int(Date().timeIntervalSince1970),
                                                                                            last_updated_by: UIDevice.current.identifierForVendor?.uuidString ?? "0"),
                                                              revision: nil)
                
                guard let data = try? JSONEncoder().encode(networkTodoItem) else { return }
                
                print(try! JSONDecoder().decode(OperationTodoItemNetworkModel.self, from: data))
                
                if self.isNew {
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
                    self.networkService.putTodoItem(id: self.id ?? "0", revision: self.revision, data: data) { result in
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
            }
            self.delegate?.closeScreen()
        }
    }

    private func rerender() {
        render?.render(props: buildProps())
    }
}
