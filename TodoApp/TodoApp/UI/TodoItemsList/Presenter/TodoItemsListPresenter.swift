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
    func todoItemsCellDidTap(id: String)
    func createNewCell(id: String)
}

class TodoItemsListPresenter: TodoItemsListPresenterProtocol {
    private var render: (Rendering & UIViewController)?
    private let fileCache: FileCache
    private var todoItems = [TodoItemCellProps]()
    private var isShowAll = true
    private var delegate: TodoItemsListDelegate?
    private var counterId: Int = 0
    
    init(fileCache: FileCache, sceneDelegate: TodoItemsListDelegate) {
        self.fileCache = fileCache
        self.delegate = sceneDelegate
        fileCache.loadTodoItemsFromJsonFile(file: "TodoItems.json")
        var counter = 0
        for item in fileCache.todoItems {
            counterId = max(counterId, Int(item.key) ?? 0)
            todoItems.append(TodoItemCellProps(deadline: item.value.deadline?.toString(),
                                               text: item.value.text,
                                               checkButtonProps: TodoItemCellProps.CheckButtonProps(isDone: item.value.isDone, id: counter, importance: item.value.importance,
                                                                                                    onToggle: nil),
                                               id: item.value.id, openCell: nil, deleteCell: nil))
            
            counter += 1
        }
        counterId += 1
    }
    
    func build() {
        render = TodoItemsListViewController()
    }
    
    func update() {
        updateCells()
        self.rerender()
    }
    
    func updateCells() {
        self.todoItems = [TodoItemCellProps]()
        var counter = 0
        for item in fileCache.todoItems {
            todoItems.append(TodoItemCellProps(deadline: item.value.deadline?.toString(),
                                               text: item.value.text,
                                               checkButtonProps: TodoItemCellProps.CheckButtonProps(isDone: item.value.isDone, id: counter, importance: item.value.importance,
                                                                                                    onToggle: nil),
                                               id: item.value.id, openCell: nil, deleteCell: nil))
            
            counter += 1
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
                self?.delegate?.todoItemsCellDidTap(id: item.id)
            }, deleteCell: deleteCell(item.id)))
            
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
            self?.delegate?.createNewCell(id: String(self?.counterId ?? 0))
            self?.counterId += 1
        })
    }
    
    private func rerender() {
        render?.render(props: buildProps())
    }
    
    func onToggle(_ at: Int) -> (() -> ()) {
        return { [weak self, at] in
            guard let self else { return }
            
            self.todoItems[at].checkButtonProps.isDone = !self.todoItems[at].checkButtonProps.isDone
            self.rerender()
        }
    }
    
    func deleteCell(_ id: String) -> (() -> ()) {
        return { [weak self, id] in
            guard let self else { return }
            
            let _ = self.fileCache.removeItem(id: id)
            updateCells()
            self.rerender()
        }
    }
}
