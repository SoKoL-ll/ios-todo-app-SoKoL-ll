//
//  TodoItemNetworkModel.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 07.07.2023.
//

import Foundation

struct TodoItemNetworkModel: Codable {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Int?
    let done: Bool
    let created_at: Int
    let changed_at: Int
    let last_updated_by: String
}

