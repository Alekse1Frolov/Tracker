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
        print("🟢 Создаём категорию: \(category.title)")
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        category.trackers.forEach { tracker in
            print("➡️ Добавляем трекер \(tracker.name) в категорию \(category.title)")
            TrackerStore(context: context).createTracker(from: tracker)
        }
        
        CoreDataStack.shared.saveContext()
        print("✅ Категория \(category.title) сохранена.")
    }


    
    func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching category: \(error)")
            return nil
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()

        do {
            let categories = try context.fetch(fetchRequest)
            print("✅ Найдено \(categories.count) категорий")
            categories.forEach { category in
                let trackers = (category.trackers as? Set<TrackerCoreData>)?.map { $0.name ?? "Без названия" } ?? []
                print("🔍 Категория: \(category.title ?? "Без названия"), Трекеры: \(trackers)")
            }
            return categories
        } catch {
            print("❌ Ошибка при загрузке категорий: \(error)")
            return []
        }
    }

}
