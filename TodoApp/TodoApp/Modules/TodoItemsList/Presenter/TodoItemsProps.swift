//
//  TodoItemsProps.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 29.06.2023.
//

import Foundation
import TodoItemPackage

struct TodoItemsProps {
    let todoItemsCells: [TodoItemCellProps]
    let tableHeaderProps: TableHeaderProps
    let createCell: (() -> ())?
    
    struct TableHeaderProps {
        let numberOdone: Int
        let isShowAll: Bool
        let showDone: (() -> ())?
    }
}

struct TodoItemCellProps {
    let deadline: String?
    let text: String
    var checkButtonProps: CheckButtonProps
    let id: String
    let openCell: (() -> ())?
    let deleteCell: (() -> ())?
    
    struct CheckButtonProps {
        var isDone: Bool
        let importance: Importance
        let onToggle: (() -> ())?
    }
}


