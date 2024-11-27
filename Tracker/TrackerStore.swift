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
        
        let categoryStore = TrackerCategoryStore(context: context)
        if let homeCategory = categoryStore.fetchCategory(byTitle: "Домашний уют") {
            trackerCoreData.category = homeCategory
        } else {
            let newCategory = TrackerCategory(title: "Домашний уют", trackers: [])
            categoryStore.createCategory(from: newCategory)
            trackerCoreData.category = categoryStore.fetchCategory(byTitle: "Домашний уют")
        }
        
        tracker.schedule.forEach { weekday in
            if let weekdayCoreData = WeekdayStore(context: context).fetchWeekdayCoreData(for: weekday) {
                trackerCoreData.addToSchedule(weekdayCoreData)
            } else {
                if let newWeekdayCoreData = WeekdayStore(context: context).createWeekday(from: weekday) {
                    trackerCoreData.addToSchedule(newWeekdayCoreData)
                }
            }
        }
        CoreDataStack.shared.saveContext()
    }
    
    func fetchAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let trackersCoreData = try context.fetch(fetchRequest)
            let recordStore = TrackerRecordStore(context: context)
            return trackersCoreData.map { Tracker(coreDataTracker: $0, recordStore: recordStore) }
        } catch {
            print("❌ Ошибка загрузки трекеров из Core Data: \(error)")
            return []
        }
    }

}
