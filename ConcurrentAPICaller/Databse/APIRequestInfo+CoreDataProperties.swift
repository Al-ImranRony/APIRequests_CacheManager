//
//  APIRequestInfo+CoreDataProperties.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/30/23.
//
//

import Foundation
import CoreData


extension APIRequestInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APIRequestInfo> {
        return NSFetchRequest<APIRequestInfo>(entityName: "APIRequestInfo")
    }

    @NSManaged public var id: Int32
    @NSManaged public var methodType: String?
    @NSManaged public var params: NSObject?
    @NSManaged public var url: String?

}

extension APIRequestInfo : Identifiable {

}
