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
    private let fileCache: FileCache
    private var todoItem: TodoItemProps?
    private var id: String?
    private var delegate: SetupTodoItemDelegate?
    
    init(fileCache: FileCache, sceneDelegate: SetupTodoItemDelegate) {
        self.fileCache = fileCache
        self.delegate = sceneDelegate
    }
    
    func build() {
        render = SetupTodoItemViewController()
    }
    
    func setupWithTodoItem(id: String) {
        self.id = id
        let todoItem = fileCache.todoItems[id]
        self.todoItem = TodoItemProps(deadline: todoItem?.deadline, text: todoItem?.text ?? "", importance: todoItem?.importance ?? .common, isDataPickerOpen: false, isSwitcherState: false, didOpenDatapiker: nil, textDidChange: nil, switchChange: nil, setNewDate: nil, cancel: nil, saveTodoItem: nil, updateDate: nil, updateImportance: nil, deleteItem: nil)
        
        if let _ = self.todoItem?.deadline {
            self.todoItem?.isSwitcherState = true
        }
    }
    
    func setupNewTodoItem(id: String) {
        self.id = id
        let todoItem = TodoItem(text: id, importance: .common, isDone: false, creationDate: Date())
        self.todoItem = TodoItemProps(text: "", importance: todoItem.importance, isDataPickerOpen: false, isSwitcherState: false, didOpenDatapiker: nil, textDidChange: nil, switchChange: nil, setNewDate: nil, cancel: nil, saveTodoItem: nil, updateDate: nil, updateImportance: nil, deleteItem: nil)
    }
    
    func open() -> UIViewController {
        render?.render(props: buildProps())
        
        return render ?? UIViewController()
    }
    
    private func buildProps() -> TodoItemProps {
        TodoItemProps(deadline: todoItem?.deadline, text: todoItem?.text ?? "", importance: todoItem?.importance ?? .common, isDataPickerOpen: todoItem?.isDataPickerOpen ?? false, isSwitcherState: todoItem?.isSwitcherState ?? false, didOpenDatapiker: { [weak self] in
            guard let self else { return }
            guard var todoItem = self.todoItem else { return }
            todoItem.isDataPickerOpen = !todoItem.isDataPickerOpen
            self.todoItem = todoItem
            self.rerender()
        }, textDidChange: { [weak self] text in
            guard let self else { return }
            self.todoItem?.text = text
        },
        switchChange: { [weak self] in
            guard let self else { return }
            guard var todoItem = self.todoItem else { return }
            todoItem.isSwitcherState = !todoItem.isSwitcherState
            if todoItem.deadline == nil {
                todoItem.deadline = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            }
            self.todoItem = todoItem
            self.rerender()
        }, setNewDate: nil, cancel: { [weak self] in
            self?.delegate?.closeScreen()
            
        }, saveTodoItem: saveTodoItem(),
        updateDate: { [weak self] date in
            guard let self else { return }
            self.todoItem?.deadline = date
            self.rerender()
        }, updateImportance: { [weak self] importance in
            guard let self else { return }
            self.todoItem?.importance = importance
        }, deleteItem: deleteItem(self.id ?? ""))
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
            self.fileCache.appendNewItem(item: TodoItem(id: self.id ?? "", text: todoItem.text, importance: todoItem.importance, deadline: todoItem.deadline, isDone: false, creationDate: Date(), modifiedDate: nil))
            self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
            self.delegate?.closeScreen()
        }
    }

    private func rerender() {
        render?.render(props: buildProps())
    }
}
