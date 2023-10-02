//
//  CoreDataStack.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 8/30/23.
//

import Foundation
import CoreData


class CoreDataStack: NSObject {
    static let shared = CoreDataStack()
    
    let moduleName = "ConcurrentAPICaller"

    func saveToMainContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error: \(nserror.localizedDescription)")
            }
        }
    }

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var applicationDocumentsDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "APIRequestInfo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error: \(error.localizedDescription)")
            }
        })
        return container
    }()
    
    func getContext() -> NSManagedObjectContext? {
        let container = persistentContainer
        return container.viewContext
    }
}
