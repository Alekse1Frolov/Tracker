//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    func createCategory(from category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        category.trackers.forEach { tracker in
            TrackerStore(context: context).createTracker(from: tracker)
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        return try? context.fetch(fetchRequest).first
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка при получении категорий: \(error)")
            return []
        }
    }

}
