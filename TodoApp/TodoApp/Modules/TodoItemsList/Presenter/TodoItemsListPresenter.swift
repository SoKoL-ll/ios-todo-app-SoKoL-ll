//
//  TodoItemsListPresenter.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 27.06.2023.
//

import Foundation
import UIKit
import TodoItemPackage
import CocoaLumberjack

protocol TodoItemsListDelegate {
    func todoItemsCellDidTap(id: String, revision: Int)
    func createNewCell(id: String, revision: Int)
}

class TodoItemsListPresenter: TodoItemsListPresenterProtocol {
    private var render: (Rendering & UIViewController)?
    private let fileCache: FileCache
    private let networkService: NetworkService
    private var todoItems = [TodoItemCellProps]()
    private var isShowAll = true
    private var delegate: TodoItemsListDelegate?
    private var counterId: Int = 0
    var revision: Int = 0
    
    init(fileCache: FileCache, sceneDelegate: TodoItemsListDelegate, networkService: NetworkService) {
        self.fileCache = fileCache
        self.delegate = sceneDelegate
        self.networkService = networkService
        update()
    }
    
    func build() {
        render = TodoItemsListViewController()
    }
    
    func update() {
        updateCells()
    }
    
    func updateCells() {
        self.todoItems = [TodoItemCellProps]()
        self.counterId = 0
        var counter = 0
        for item in fileCache.todoItems {
            todoItems.append(TodoItemCellProps(deadline: item.value.deadline?.toString(),
                                               text: item.value.text,
                                               checkButtonProps: TodoItemCellProps.CheckButtonProps(isDone: item.value.isDone, id: counter, importance: item.value.importance,
                                                                                                    onToggle: nil),
                                               id: item.value.id, openCell: nil, deleteCell: nil))

            counter += 1
        }
        DispatchQueue.global().async {
            if SyncTodoItems.isDirty {
                self.patchItems()
            }
            self.networkService.getAllTodoItems { result in
                switch result {
                case.success(let response):
                    self.revision = response.revision ?? 0
                    self.fileCache.todoItems = [:]
                    guard let todoItems = response.list else { return }
                    self.todoItems = [TodoItemCellProps]()
                    for item in todoItems {
                        self.counterId = max(self.counterId, Int(item.id) ?? 0)
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
                        self.todoItems.append(TodoItemCellProps(
                            deadline: setDeadline?.toString(),
                            text: item.text,
                            checkButtonProps: TodoItemCellProps.CheckButtonProps(
                                isDone: item.done,
                                id: 0,
                                importance: item.importance,
                                onToggle: nil
                            ),
                            id: item.id,
                            openCell: nil,
                            deleteCell: nil)
                        )
                    }
                    self.fileCache.saveTodoItemsToJsonFile(file: "TodoItems.json")
                    
                    DispatchQueue.main.async {
                        self.rerender()
                    }
                case .failure(let error):
                    SyncTodoItems.isDirty = true
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    func patchItems() {
        DispatchQueue.global().async {
            var listOfItems: [TodoItemNetworkModel] = []
            
            for item in self.fileCache.todoItems {
                listOfItems.append(TodoItemNetworkModel(id: item.value.id,
                                                        text: item.value.text,
                                                        importance: item.value.importance,
                                                        deadline: item.value.deadline?.timeIntervalSince1970.exponent,
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
                    SyncTodoItems.isDirty = false
                    self.counterId = 0
                    self.revision = response.revision ?? 0
                    guard let todoItems = response.list else { return }
                    for item in todoItems {
                        self.counterId = max(self.counterId, Int(item.id) ?? 0)
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
                        self.todoItems.append(TodoItemCellProps(
                            deadline: setDeadline?.toString(),
                            text: item.text,
                            checkButtonProps: TodoItemCellProps.CheckButtonProps(
                                isDone: item.done,
                                id: 0,
                                importance: item.importance,
                                onToggle: nil
                            ),
                            id: item.id,
                            openCell: nil,
                            deleteCell: nil)
                        )
                    }
                case .failure(let error):
                    SyncTodoItems.isDirty = true
                    print("Error occured \(error)")
                }
            }
                
        }
    }
    
    func open() -> UIViewController {
        render?.render(props: buildProps())
        
        return render ?? UIViewController()
    }
    
    private func buildProps() -> TodoItemsProps {
        var todoItemsCell = [TodoItemCellProps]()
        var counter = 0
        var numberOfDone = 0
        for item in todoItems {
            if isShowAll && item.checkButtonProps.isDone {
                counter += 1
                continue
            }
            todoItemsCell.append(TodoItemCellProps(deadline: item.deadline,
                                                   text: item.text,
                                                   checkButtonProps: TodoItemCellProps.CheckButtonProps(
                                                    isDone: item.checkButtonProps.isDone,
                                                    id: item.checkButtonProps.id,
                                                    importance: item.checkButtonProps.importance,
                                                                                                        onToggle: onToggle(counter)),
                                                    id: item.id, openCell: { [weak self] in
                if SyncTodoItems.isDirty {
                    self?.patchItems()
                }
                self?.delegate?.todoItemsCellDidTap(id: item.id, revision: self?.revision ?? 0)
            }, deleteCell: deleteCell(item.id, counter)))
            
            counter += 1
        }
        
        todoItems.forEach {
            if $0.checkButtonProps.isDone {
                numberOfDone += 1
            }
        }
        
        return TodoItemsProps(todoItemsCells: todoItemsCell, tableHeaderProps: TodoItemsProps.TableHeaderProps(numberOdone: numberOfDone, isShowAll: isShowAll, showDone: { [weak self] in
            guard let self else { return }
            self.isShowAll = !self.isShowAll
            self.rerender()
        }), createCell: {[weak self] in
            self?.counterId += 1
            self?.delegate?.createNewCell(id: String(self?.counterId ?? 0), revision: self?.revision ?? 0)
        })
    }
    
    private func rerender() {
        render?.render(props: buildProps())
    }
    
    func onToggle(_ at: Int) -> (() -> ()) {
        return { [weak self, at] in
            guard let self else { return }
            
            self.todoItems[at].checkButtonProps.isDone = !self.todoItems[at].checkButtonProps.isDone
            guard let toggleTodoItem = fileCache.todoItems[self.todoItems[at].id] else { return }
            
            DispatchQueue.global().async {
                if SyncTodoItems.isDirty {
                    self.patchItems()
                }
                let networkTodoItem = OperationTodoItemNetworkModel(element: TodoItemNetworkModel(id: toggleTodoItem.id,
                                                                                                  text: toggleTodoItem.text,
                                                                                            importance: toggleTodoItem.importance,
                                                                                                  deadline: toggleTodoItem.deadline.map { Int($0.timeIntervalSince1970) },
                                                                                                  done: self.todoItems[at].checkButtonProps.isDone,
                                                                                            created_at: Int(Date().timeIntervalSince1970),
                                                                                            changed_at: Int(Date().timeIntervalSince1970),
                                                                                            last_updated_by: UIDevice.current.identifierForVendor?.uuidString ?? "0"),
                                                              revision: nil)
                
                guard let data = try? JSONEncoder().encode(networkTodoItem) else { return }
                self.networkService.putTodoItem(id: toggleTodoItem.id, revision: self.revision, data: data) { result in
                    switch result {
                    case .success(let response):
                        self.revision = response.revision ?? 0
                        self.fileCache.appendNewItem(item: TodoItem(id: response.element.id,
                                                                    text: response.element.text,
                                                                    importance: response.element.importance,
                                                                    deadline: response.element.deadline.map { Date(timeIntervalSince1970: TimeInterval($0))},
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
            self.rerender()
        }
    }
    
    func deleteCell(_ id: String, _ pos: Int) -> (() -> ()) {
        return { [weak self, id, pos] in
            guard let self else { return }
            
            let _ = self.fileCache.removeItem(id: id)
            DispatchQueue.global().async {
                if SyncTodoItems.isDirty {
                    self.patchItems()
                }
                self.networkService.deleteTodoItem(revision: self.revision, id: id) { result in
                    switch result {
                    case.success(let response):
                        self.revision = response.revision ?? 0
                        DispatchQueue.main.async {
                            self.rerender()
                        }
                    case .failure(let error):
                        SyncTodoItems.isDirty = true
                        print("Error occured \(error)")
                    }
                }
            }
            
            todoItems.remove(at: pos)
            self.rerender()
        }
    }
}
