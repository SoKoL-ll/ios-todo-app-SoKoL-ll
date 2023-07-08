//
//  HTTPError.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 05.07.2023.
//

import Foundation

public enum HTTPError: String, Error {
    case failed = "Error: Network request failed"
    case missingURL = "Error: URL is missing"
    case missingURLComponents = "Error: URL components are missing"
    case failedResponseUnwrapping = "Error: Failed to unwrap response"
    case badRequest = "Error: Bad request"
    case authenticationError = "Error: Failed to authenticate"
    case serverSideError = "Error: Server error"
    case decodingFailed = "Error: Failed to decode data"
    case wrongRequest = "Error: wrong request / invalid url / unsynchronizedData"
    case notFound = "Error: Element not found on server."
}
