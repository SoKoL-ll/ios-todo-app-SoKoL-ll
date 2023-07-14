//
//  TodoItemsListPresenter.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 27.06.2023.
//

import Foundation
import UIKit
import CocoaLumberjack

protocol TodoItemsListDelegate {
    func todoItemsCellDidTap(id: String, revision: Int)
    func createNewCell(id: String, revision: Int)
}

class TodoItemsListPresenter: TodoItemsListPresenterProtocol {
    private var render: (Rendering & UIViewController)?
    private let storageManager: StorageManager
    private var todoItems = [TodoItemCellProps]()
    private var isShowAll = true
    private var delegate: TodoItemsListDelegate?
    var revision: Int = 0
    
    init(storageManager: StorageManager, sceneDelegate: TodoItemsListDelegate) {
        self.storageManager = storageManager
        self.delegate = sceneDelegate
        setupItems()
    }
    
    func build() {
        render = TodoItemsListViewController()
    }
    
    func update() {
        updateCells()
    }
    
    func setupItems() {
        storageManager.get { [weak self] in
            guard let self = self else { return }
            self.todoItems = self.storageManager.getFromCache()
            DispatchQueue.main.async {
                self.rerender()
            }
        }
    }
    
    func updateCells() {
        self.todoItems = storageManager.getFromCache()
    }
    
    func open() -> UIViewController {
        render?.render(props: buildProps())
        
        return render ?? UIViewController()
    }
    
    private func buildProps() -> TodoItemsProps {
        var todoItemsCell = [TodoItemCellProps]()
        var numberOfDone = 0
        for item in todoItems {
            if isShowAll && item.checkButtonProps.isDone {
                continue
            }
            todoItemsCell.append(TodoItemCellProps(deadline: item.deadline,
                                                   text: item.text,
                                                   checkButtonProps: TodoItemCellProps.CheckButtonProps(
                                                    isDone: item.checkButtonProps.isDone,
                                                    importance: item.checkButtonProps.importance,
                                                    onToggle: onToggle(item.id)
                                                   ),
                                                   id: item.id,
                                                   openCell: { [weak self] in
                self?.delegate?.todoItemsCellDidTap(id: item.id, revision: self?.revision ?? 0)
            },
                                                   deleteCell: deleteCell(item.id)))
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
            self?.delegate?.createNewCell(id: UUID().uuidString, revision: self?.revision ?? 0)
        })
    }
    
    private func rerender() {
        render?.render(props: buildProps())
    }
    
    func onToggle(_ at: String) -> (() -> ()) {
        return { [weak self, at] in
            guard let self else { return }
            
            self.storageManager.changeToggle(id: at)
            self.todoItems = self.storageManager.getFromCache()
            self.rerender()
        }
    }
    
    func deleteCell(_ id: String) -> (() -> ()) {
        return { [weak self, id] in
            guard let self else { return }
            
            self.storageManager.delete(id: id) {
                self.todoItems = self.storageManager.getFromCache()
                DispatchQueue.main.async {
                    self.rerender()
                }
            }
        }
    }
}
