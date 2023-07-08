//
//  NetworkServiceImpl.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 05.07.2023.
//

import Foundation
import UIKit

final class NetworkServiceImp: NetworkService {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getAllTodoItems(completion: @escaping (Result<TodoItemsNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createGetAllTodoItemsRequest(),
            completion: completion
        )
    }
    func getTodoItemById(id: String, completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createGetTodoItemByIdRequest(id),
            completion: completion
        )
    }

    func patchTodoItems(revision: Int, data: Data, completion: @escaping (Result<TodoItemsNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createUpdateTodoItemsRequst(revision, data),
            completion: completion
        )
    }
    
    func addTodoItem(revision: Int, data: Data, completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createAddTodoItemRequst(revision, data),
            completion: completion
        )
    }
    
    func deleteTodoItem(revision: Int, id: String, completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createDeleteTodoItemByIdRequst(revision, id),
            completion: completion
        )
    }
    
    func putTodoItem(id: String, revision: Int, data: Data, completion: @escaping (Result<OperationTodoItemNetworkModel, Error>) -> Void) {
        networkClient.processRequest(
            request: createUpdateTodoItemByIdRequst(id, revision, data),
            completion: completion
        )
    }
    
    private func createGetAllTodoItemsRequest() -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: ["Authorization": "Bearer constructiveness"]
        )
    }
    
    private func createGetTodoItemByIdRequest(_ id: String) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list/\(id)",
            headers: ["Authorization": "Bearer constructiveness"]
        )
    }
    
    private func createDeleteTodoItemByIdRequst(_ revision: Int, _ id: String) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list/\(id)",
            headers: ["Authorization": "Bearer constructiveness",
                      "X-Last-Known-Revision": "\(revision)"],
            httpMethod: .delete
        )
    }
    
    private func createUpdateTodoItemByIdRequst(_ id: String, _ revision: Int, _ data: Data) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list/\(id)",
            headers: ["Authorization": "Bearer constructiveness",
                      "X-Last-Known-Revision": "\(revision)"],
            body: data,
            httpMethod: .put
        )
    }
    
    private func createAddTodoItemRequst(_ revision: Int, _ data: Data) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: ["Authorization": "Bearer constructiveness",
                      "X-Last-Known-Revision": "\(revision)"],
            body: data,
            httpMethod: .post
            
        )
    }
    
    private func createUpdateTodoItemsRequst(_ revision: Int, _ data: Data) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: ["Authorization": "Bearer constructiveness",
                      "X-Last-Known-Revision": "\(revision)"],
            body: data,
            httpMethod: .patch
            
        )
    }
}

// MARK: - Nested types

extension NetworkServiceImp {
    enum Constants {
        static let baseurl: String = "https://beta.mrdekk.ru/todobackend"
    }
}
