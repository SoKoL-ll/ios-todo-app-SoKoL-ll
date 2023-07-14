//
//  SetupTodoItemPresenter.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit

protocol SetupTodoItemDelegate {
    func closeScreen()
}

class SetupTodoItemPresenter: SetupTodoItemPresenterProtocol {
    private var render: (SetupTodoItemRendering & UIViewController)?
    private var todoItem: TodoItemProps?
    private let storageManager: StorageManager
    private var id: String?
    private var isNew: Bool = true
    private var delegate: SetupTodoItemDelegate?
    
    init(storageManager: StorageManager, sceneDelegate: SetupTodoItemDelegate) {
        self.storageManager = storageManager
        self.delegate = sceneDelegate
    }
    
    func build() {
        render = SetupTodoItemViewController()
    }
    
    func setupWithTodoItem(id: String, revision: Int) {
        self.id = id
        self.isNew = false
        self.todoItem = storageManager.getItemFromCache(id: id)
        
        if let _ = self.todoItem?.deadline {
            self.todoItem?.isSwitcherState = true
        }
    }
    
    func setupNewTodoItem(id: String, revision: Int) {
        self.id = id
        self.isNew = true
        self.todoItem = TodoItemProps(text: "",
                                      importance: .basic,
                                      createdDate: Date(),
                                      isDone: false,
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
                      createdDate: todoItem?.createdDate ?? Date(),
                      isDone: todoItem?.isDone ?? false,
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
            
            self.storageManager.delete(id: id) { [weak self] in
                DispatchQueue.main.async {
                    self?.delegate?.closeScreen()
                }
            }
        }
    }
    
    func saveTodoItem() -> (() -> ()) {
        return { [weak self] in
            guard let self else { return }
            guard let todoItem = self.todoItem else { return }
            self.storageManager.save(id: self.id ?? UUID().uuidString, todoItem: todoItem, isNew: self.isNew) { [weak self] in
                DispatchQueue.main.async {
                    self?.delegate?.closeScreen()
                }
            }
        }
    }

    private func rerender() {
        render?.render(props: buildProps())
    }
}
