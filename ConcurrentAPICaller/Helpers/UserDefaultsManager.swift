//
//  UserDefaultsManager.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 8/30/23.
//

import Foundation


enum UserDefaultOperation: String {
    case uniqueUserID = "userUniqueIdentifier"
    
    case initiatedCallsKey = "InitiatedCallsKey"
    case requestCounterKey = "requestCounterKey"
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    func setObject(obj: Any, operation: UserDefaultOperation) {
        defaults.set(obj, forKey: operation.rawValue)
    }
    
    func setAPIRequestTags(tags: [Int]) {
        defaults.set(tags, forKey: UserDefaultOperation.requestCounterKey.rawValue)
        defaults.synchronize()
    }
    
    func getAPIRequestTags() -> Array<Int> {
        let tags: Array<Int> = defaults.object(forKey: UserDefaultOperation.requestCounterKey.rawValue) as? [Int] ?? [Int]()
        return tags
    }

}
