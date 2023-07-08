//
//  TodoItemProps.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 30.06.2023.
//

import Foundation
import TodoItemPackage

struct TodoItemProps {
    var deadline: Date?
    var text: String
    var importance: Importance
    
    var isDataPickerOpen: Bool
    var isSwitcherState: Bool
    let didOpenDatapiker: (() ->())?
    let textDidChange: ((_ text: String) -> ())?
    let switchChange: (() -> ())?
    let setNewDate: (() -> ())?
    let cancel: (() -> ())?
    let saveTodoItem: (() -> ())?
    let updateDate: ((_ date: Date) -> ())?
    let updateImportance: ((_ importance: Importance) -> ())?
    let deleteItem: (() -> ())?
}
