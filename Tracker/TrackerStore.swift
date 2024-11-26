//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var didChangeContent: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        super.init()
    }
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
    }
    
    func getAllTrackers() -> [TrackerCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeContent?()
    }
    
    // MARK: - Create
    func createTracker(from tracker: Tracker) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.emoji = tracker.emoji
        
        tracker.schedule.forEach { weekday in
            if let weekdayCoreData = WeekdayStore(context: context).fetchWeekdayCoreData(for: weekday) {
                trackerCoreData.addToSchedule(weekdayCoreData)
            }
        }
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Read
    func fetchAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            let trackers = trackersCoreData.map { coreData in
                Tracker(
                    id: coreData.id ?? UUID(),
                    name: coreData.name ?? "",
                    color: UIColor(hex: coreData.color ?? "#FFFFFF"),
                    emoji: coreData.emoji ?? "",
                    schedule: (coreData.schedule as? Set<WeekdayCoreData>)?.compactMap {
                        WeekdayStore(context: context).weekday(from: $0)
                    } ?? []
                )
            }
            return trackers
        } catch {
            return []
        }
    }
    
    // MARK: - Delete
    func deleteTracker(with id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            CoreDataStack.shared.saveContext()
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }
}
