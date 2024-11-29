//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private let modelName = Constants.coreDataStackModelName
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
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
