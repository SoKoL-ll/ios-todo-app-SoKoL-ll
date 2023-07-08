//
//  NetworkService.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 05.07.2023.
//

import Foundation

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        completion: @escaping (Result<TodoItemsNetworkModel, Error>) -> Void
    )
    
    func getTodoItemById(
        id: String,
        completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void
    )
    
    func patchTodoItems(
        revision: Int,
        data: Data,
        completion: @escaping (Result<TodoItemsNetworkModel, Error>) -> Void
    )
    
    func addTodoItem(
        revision: Int,
        data: Data,
        completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void
    )
    
    func deleteTodoItem(
        revision: Int,
        id: String,
        completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void
    )
    
    func putTodoItem(
        id: String,
        revision: Int,
        data: Data,
        completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void
    )
}
