//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var onDataChange: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    func setupFetchedResultsController(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(key: "order", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title", // Группируем по категориям
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
    }
    
    func createTracker(from tracker: Tracker) {
        print("🟢 Создаём трекер: \(tracker.name), ID: \(tracker.id)")
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let existingTracker = try? context.fetch(fetchRequest).first {
            print("⚠️ Трекер \(tracker.name) уже существует в Core Data, добавление пропущено.")
            return
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.date = tracker.date
        
        print("➡️ Устанавливаем категорию для трекера: \(tracker.category)")
        if let category = TrackerCategoryStore(context: context).fetchCategory(byTitle: tracker.category) {
            print("✅ Связь с категорией \(category.title ?? "Без названия") добавлена")
            trackerCoreData.category = category
            
            if let trackers = category.trackers as? Set<TrackerCoreData> {
                trackerCoreData.order = Int16(trackers.count)
            } else {
                trackerCoreData.order = 0
            }
        } else {
            print("⚠️ Категория \(tracker.category) не найдена, создаём новую категорию")
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = tracker.category
            context.insert(newCategory)
            trackerCoreData.category = newCategory
            print("✅ Категория \(tracker.category) сохранена.")
            trackerCoreData.order = 0
        }
        
        
        tracker.schedule.forEach { weekday in
            if let weekdayCoreData = WeekdayStore(context: context).fetchWeekday(for: weekday) {
                trackerCoreData.addToSchedule(weekdayCoreData)
            } else {
                let newWeekday = WeekdayCoreData(context: context)
                newWeekday.number = Int16(weekday.rawValue)
                newWeekday.name = weekday.displayName
                trackerCoreData.addToSchedule(newWeekday)
                print("✅ День недели \(weekday.displayName) сохранён.")
            }
        }
        do {
            try context.save()
            print("✅ Трекер \(tracker.name) сохранён.")
        } catch {
            print("❌ Ошибка при сохранении трекера \(tracker.name): \(error)")
        }
    }
    
    func fetchAllTrackers(for weekday: Weekday) -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try context.fetch(fetchRequest)
            let trackers = results.compactMap { Tracker(coreDataTracker: $0) }
            return trackers.filter { $0.schedule.contains(weekday) }
        } catch {
            print("❌ Ошибка при загрузке трекеров: \(error)")
            return []
        }
    }
    
    
    func fetchTracker(byID id: UUID) -> Tracker? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                return Tracker(coreDataTracker: trackerCoreData)
            }
        } catch {
            print("⚠️ Ошибка при поиске трекера по ID \(id): \(error)")
        }
        return nil
    }
    
    func fetchTrackers(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try fetchedResultsController?.performFetch()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDataChange?()
    }
}
