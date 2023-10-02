//
//  APIRequestInfo+CoreDataClass.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/29/23.
//
//

import CoreData
import UIKit


@objc(APIRequestInfo)
public class APIRequestInfo: NSManagedObject {
    
    let coreDataStack = CoreDataStack()
    
    class func createData(requestInfo: RequestInfo, context: NSManagedObjectContext) throws -> APIRequestInfo {
        let fetchRequest: NSFetchRequest<APIRequestInfo> = APIRequestInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", requestInfo.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            // Process the fetched records
            for apiRequestInfo in results {
                print("URL: \(apiRequestInfo.url)")
                print("Method: \(apiRequestInfo.method)")
                print("Timestamp: \(apiRequestInfo.id)")
                print("Parameters: \(apiRequestInfo.params)")
            }
            
            try? context.save()
        } catch {
            print("Fetch error: \(error)")
            throw error
        }
        
        let requestInfo = APIRequestInfo(context: context)
        requestInfo.id = requestInfo.id
        requestInfo.url = requestInfo.url
        requestInfo.methodType = requestInfo.methodType
        requestInfo.params = requestInfo.params
        
        return requestInfo
    }

    class func saveToDB(requestInfo: APIRequestInfo, complition: @escaping ()->()) {
        if let context = CoreDataStack.shared.getContext() {
            var apiRequestInfo = APIRequestInfo(context: context)
            apiRequestInfo = requestInfo
            do {
                try context.save()
            } catch {
                print("Core data saving error: \(error.localizedDescription)")
            }
            complition()
        }
    }
    
    class func fetchStoredInfo(requestTag: Int, complition: @escaping (RequestInfo)->()) {
        let fetchRequest: NSFetchRequest<APIRequestInfo> = APIRequestInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %i", Int64(requestTag))
        
        var params = Parameters(appID: "", quidd: "", name: "", params: "")
        var fetchedInfo = RequestInfo(id: 0, url: "", method: "", parameters: params)
        DispatchQueue.main.async {
            if let context = CoreDataStack.shared.getContext() {
                do {
                    let results = try context.fetch(fetchRequest)
                    for apiRequestInfo in results {
                        if let urlString = apiRequestInfo.url,
                           let methodType = apiRequestInfo.methodType {
                            fetchedInfo.url = urlString
                            fetchedInfo.method = methodType
                        }
                        if let parameters = apiRequestInfo.params as? Parameters {
                            params.appID = parameters.appID
                            params.quidd = parameters.quidd
                            params.name = parameters.name
                            params.params = parameters.params
                        }
                        fetchedInfo.parameters = params

                        fetchedInfo.id = Int(apiRequestInfo.id)
                        complition(fetchedInfo)
                    }
                } catch {
                    print("Fetch error: \(error)")
                }
            }
        }
    }
    
    class func removeFromDB(requestInfo: APIRequestInfo, complition: @escaping ()->()) {
        let fetchRequest: NSFetchRequest<APIRequestInfo> = APIRequestInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %i", Int32(requestInfo.id))
        
        DispatchQueue.main.async {
            if let context = CoreDataStack.shared.getContext() {
                do {
                    let results = try context.fetch(fetchRequest)
                    for apiRequestInfo in results {
                        context.delete(apiRequestInfo)
                    }
                    try? context.save()
                } catch {
                    print("Fetch error: \(error)")
                }
                complition()
            }
        }
    }
}
