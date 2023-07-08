//
//  HTTPNetworkResponse.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 05.07.2023.
//

import Foundation

struct HTTPNetworkResponse {
    static func handleNetworkResponse(for response: HTTPURLResponse?) -> Result<Void, HTTPError> {
        guard let response = response else {
            return .failure(HTTPError.failedResponseUnwrapping)
        }
        switch response.statusCode {
        case 200: return .success(())
        case 400: return .failure(HTTPError.wrongRequest)
        case 401: return .failure(HTTPError.authenticationError)
        case 404: return .failure(HTTPError.notFound)
        case 500...599: return .failure(HTTPError.serverSideError)
        default: return .failure(HTTPError.failed)
        }
    }
}
