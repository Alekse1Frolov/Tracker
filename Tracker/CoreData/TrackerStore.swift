//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let pinnedCategoryTitle = "Закреплённые"
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var onDataChange: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        super.init()
        
        ensurePinnedCategoryExists()
    }
    
    private func ensurePinnedCategoryExists() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", pinnedCategoryTitle)
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            if existingCategories.isEmpty {
                let pinnedCategory = TrackerCategoryCoreData(context: context)
                pinnedCategory.title = pinnedCategoryTitle
                try context.save()
            }
        } catch {
            print("Ошибка при создании категории \(pinnedCategoryTitle): \(error)")
        }
    }
    
    func setupFetchedResultsController(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors ?? [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "order", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
    }
    
    func createTracker(from tracker: Tracker) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.date = tracker.date
        
        if let category = TrackerCategoryStore(context: context).fetchCategory(byTitle: tracker.category) {
            trackerCoreData.category = category
            trackerCoreData.order = Int16((category.trackers as? Set<TrackerCoreData>)?.count ?? 0)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = tracker.category
            trackerCoreData.category = newCategory
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
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Трекер не сохранен: \(error)")
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
            print("Ошибка при загрузке трекера из Core Data: \(error)")
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
    
    func fetchCategory(for title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при загрузке категории \(title): \(error)")
            return nil
        }
    }
    
    func updateTracker(
        _ tracker: Tracker,
        name: String,
        color: String,
        emoji: String,
        schedule: [Weekday],
        category: String
    ) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                trackerCoreData.name = name
                trackerCoreData.color = color
                trackerCoreData.emoji = emoji
                
                trackerCoreData.schedule?.forEach { context.delete($0 as! NSManagedObject) }
                schedule.forEach { weekday in
                    if let weekdayCoreData = WeekdayStore(context: context).fetchWeekday(for: weekday) {
                        trackerCoreData.addToSchedule(weekdayCoreData)
                    } else {
                        let newWeekday = WeekdayCoreData(context: context)
                        newWeekday.number = Int16(weekday.rawValue)
                        newWeekday.name = weekday.displayName
                        trackerCoreData.addToSchedule(newWeekday)
                    }
                }
                
                if let categoryCoreData = TrackerCategoryStore(context: context).fetchCategory(byTitle: category) {
                    trackerCoreData.category = categoryCoreData
                } else {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = category
                    trackerCoreData.category = newCategory
                }
                
                try context.save()
            }
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
    
    func updatePinStatus(for trackerID: UUID, isPinned: Bool) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                tracker.isPinned = isPinned
                try context.save()
            }
        } catch {
            print("Ошибка при обновлении состояния закрепления: \(error)")
        }
    }
    
    func deleteTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                context.delete(tracker)
                try context.save()
            }
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDataChange?()
    }
}

extension TrackerStore {
    func pinTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            print("Начало закрепления трекера с ID: \(id)")
            if let tracker = try context.fetch(fetchRequest).first {
                print("Трекер найден: \(tracker.name ?? "без названия")")
                
                if let currentCategory = tracker.category {
                    tracker.previousCategory = currentCategory.title
                    print("Предыдущая категория: \(currentCategory.title ?? "Не указана") сохранена")
                }
                
                let pinnedCategory = fetchCategory(for: pinnedCategoryTitle) ?? {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = pinnedCategoryTitle
                    print("Категория 'Закреплённые' создана")
                    return newCategory
                }()
                
                tracker.category = pinnedCategory
                tracker.isPinned = true
                print("Трекер \(tracker.name ?? "без названия") перемещён в категорию 'Закреплённые'")
                
                try context.save()
                print("Трекер \(tracker.name ?? "без названия") успешно закреплён")
                
                self.onDataChange?()
            } else {
                print("Ошибка: Трекер с ID \(id) не найден")
            }
        } catch {
            print("Ошибка при закреплении трекера с ID \(id): \(error)")
        }
    }
    
    func unpinTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            print("Начало открепления трекера с ID: \(id)")
            if let tracker = try context.fetch(fetchRequest).first {
                print("Трекер найден: \(tracker.name ?? "без названия")")
                
                if let previousCategoryTitle = tracker.previousCategory {
                    print("Предыдущая категория: \(previousCategoryTitle)")
                    if let previousCategory = fetchCategory(for: previousCategoryTitle) {
                        tracker.category = previousCategory
                        print("Трекер перемещён обратно в категорию: \(previousCategory.title ?? "Не указана")")
                    } else {
                        print("Ошибка: Предыдущая категория \(previousCategoryTitle) не найдена")
                    }
                    tracker.previousCategory = nil
                } else {
                    print("Ошибка: У трекера нет сохранённой предыдущей категории")
                }
                
                tracker.isPinned = false
                print("Флаг закрепления трекера сброшен")
                
                try context.save()
                print("Трекер \(tracker.name ?? "без названия") успешно откреплён")
                
                DispatchQueue.main.async { [weak self] in
                    self?.onDataChange?()
                }
            } else {
                print("Ошибка: Трекер с ID \(id) не найден")
            }
        } catch {
            print("Ошибка при откреплении трекера с ID \(id): \(error)")
        }
    }
    
    private func fetchPinnedCategory() -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", pinnedCategoryTitle)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при получении категории \"Закреплённые\": \(error)")
            return nil
        }
    }
    
    func fetchCategory(for trackerID: UUID) -> String? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                return tracker.category?.title
            }
        } catch {
            print("Ошибка при загрузке категории для трекера: \(error)")
        }
        return nil
    }
}

