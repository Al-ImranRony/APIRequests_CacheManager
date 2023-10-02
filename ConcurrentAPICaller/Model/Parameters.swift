//
//  Parameters.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/29/23.
//

import Foundation


@objc public class Parameters: NSObject, Codable, NSCoding {
    var appID, quidd, name, params: String

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case quidd = "quidd"
        case name = "name"
        case params = "params"
    }
    
    init(appID: String, quidd: String, name: String, params: String) {
        self.appID = appID
        self.quidd = quidd
        self.name = name
        self.params = params
    }
    
    public required convenience init?(coder: NSCoder) {
        let appID = coder.decodeObject(forKey: CodingKeys.appID.rawValue) as? String
        let quidd = coder.decodeObject(forKey: CodingKeys.quidd.rawValue) as? String
        let name = coder.decodeObject(forKey: CodingKeys.name.rawValue) as? String
        let params = coder.decodeObject(forKey: CodingKeys.params.rawValue) as? String
        
        self.init(appID: appID ?? "", quidd: quidd ?? "", name: name ?? "", params: params ?? "")
    }
    
    public func encode(with coder: NSCoder) {
        let appID = NSKeyedArchiver.archivedData(withRootObject: appID)
        coder.encode(appID, forKey: CodingKeys.appID.rawValue)
        let quidd = NSKeyedArchiver.archivedData(withRootObject: quidd)
        coder.encode(quidd, forKey: CodingKeys.quidd.rawValue)
        let name = NSKeyedArchiver.archivedData(withRootObject: name)
        coder.encode(name, forKey: CodingKeys.name.rawValue)
        let params = NSKeyedArchiver.archivedData(withRootObject: params)
        coder.encode(params, forKey: CodingKeys.params.rawValue)
    }
}
