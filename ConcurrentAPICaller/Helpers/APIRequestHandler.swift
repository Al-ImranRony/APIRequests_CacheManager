//
//  APIRequestHandler.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/28/23.
//

import Combine
import Foundation


enum HTTPMethodType: String, CaseIterable {
    case get = "GET"
    case post = "POST"
}

class APIRequestHandler {
    func makeRequest(method: HTTPMethodType, url: URL, parameters: [String: Any]? = nil) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method == .post, let parameters = parameters {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { error in
                return error
            }
            .eraseToAnyPublisher()
    }
}
