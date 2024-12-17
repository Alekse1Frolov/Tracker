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
    
    func fetchTrackers(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try fetchedResultsController?.performFetch()
            completion(.success(()))
        } catch {
            completion(.failure(error))
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
