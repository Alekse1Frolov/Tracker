//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import UIKit
import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private let modelName: String = "TrackerModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        let storeDescriptions = [
            createStoreDescription(for: "TrackerCategoryCoreData"),
            createStoreDescription(for: "TrackerCoreData"),
            createStoreDescription(for: "TrackerRecordCoreData"),
            createStoreDescription(for: "WeekdayCoreData")
        ]
        
        container.persistentStoreDescriptions = storeDescriptions
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    private func createStoreDescription(for entityName: String) -> NSPersistentStoreDescription {
        let storeURL = URL(
            fileURLWithPath: "\(entityName).sqlite",
            relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        )
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSSQLiteStoreType
        return description
    }
    
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
