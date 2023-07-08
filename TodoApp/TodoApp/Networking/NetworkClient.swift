//
//  NetworkClient.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 06.07.2023.
//

import Foundation

protocol NetworkClient {
    @discardableResult
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}
