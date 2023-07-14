//
//  AddTodoItemNetworkModel.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 07.07.2023.
//

import Foundation

struct OperationTodoItemNetworkModel: Codable {
    let element: TodoItemNetworkModel
    let revision: Int?
}
