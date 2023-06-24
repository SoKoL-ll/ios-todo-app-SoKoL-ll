//
//  SetupTodoItemPresenterProtocol.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation

protocol SetupTodoItemPresenterProtocol: AnyObject {
    func dateDidChanged(date: Date)
    func updateDescriptionField(text: String)
    func updateImportance(importance: Importance)
    func saveTodoItem()
    func deleteTodoItem()
}
