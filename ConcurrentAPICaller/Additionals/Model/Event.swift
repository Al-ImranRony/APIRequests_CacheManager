//
//  Event.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 8/27/23.
//

import Foundation


struct Event: Codable {
    let appID, quidd, name: String
    let params: Params

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case quidd, name, params
    }
}

struct Params: Codable {
    let param1: String
}
