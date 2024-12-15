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
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при получении категории с названием \(title): \(error.localizedDescription)")
            return nil
        }
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
    
    func updateCategory(oldTitle: String, newTitle: String) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        do {
            if let categoryToUpdate = try context.fetch(fetchRequest).first {
                categoryToUpdate.title = newTitle
                try context.save()
                return true
            }
        } catch {
            print("Ошибка при изменении категории: \(error)")
        }
        return false
    }
    
    func deleteCategory(byTitle title: String) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            if let categoryToDelete = try context.fetch(fetchRequest).first {
                context.delete(categoryToDelete)
                try context.save()
                return true
            }
        } catch {
            print("Не получилось удалить категорию \(error)")
        }
        return false
    }
}