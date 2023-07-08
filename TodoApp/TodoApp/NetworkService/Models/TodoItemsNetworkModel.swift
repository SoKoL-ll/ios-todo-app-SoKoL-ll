//
//  TodoItemNetworkModel.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 05.07.2023.
//

import Foundation
import TodoItemPackage

struct TodoItemsNetworkModel: Codable {
    let status: String?
    let list: [TodoItemNetworkModel]?
    let revision: Int?
}
