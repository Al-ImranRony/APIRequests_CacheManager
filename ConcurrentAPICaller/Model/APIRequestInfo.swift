//
//  APIRequestInfo.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/28/23.
//

import Foundation


@objc public class RequestInfo: NSObject, Codable {
    var id: Int = 0
    var url: String = ""
    var method: String = ""
    var parameters: Parameters
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case method = "method"
        case parameters = "parameters"
    }
    
    init(id: Int, url: String, method: String, parameters: Parameters) {
        self.id = id
        self.url = url
        self.method = method
        self.parameters = parameters
    }
    
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        url = try values.decode(String.self, forKey: .url)
        method = try values.decode(String.self, forKey: .method)
        parameters = try values.decode(Parameters.self, forKey: .parameters)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(method, forKey: .method)
        try container.encode(parameters, forKey: .parameters)
    }
}
