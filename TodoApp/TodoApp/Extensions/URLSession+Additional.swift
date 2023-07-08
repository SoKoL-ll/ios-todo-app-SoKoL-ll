//
//  URLSession+Additional.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 08.07.2023.
//

import Foundation

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
                guard let data = data,
                      let response = response
                else {
                    let error = NSError(domain: "URLSession", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response or data received"])
                    continuation.resume(throwing: error)
                    return
                }
                DispatchQueue.main.async {
                    continuation.resume(returning: (data, response))
                }
            }
            
            if Task.isCancelled {
                task.cancel()
            } else {
                task.resume()
            }
        }
    }
}
