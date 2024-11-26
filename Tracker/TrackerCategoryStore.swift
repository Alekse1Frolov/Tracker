//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    var didChangeContent: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        super.init()
    }
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        try? fetchedResultsController?.performFetch()
    }
    
    func getAllCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeContent?()
    }
    
    // MARK: - Create
    func createCategory(from category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        // Связываем Trackers с категорией
        category.trackers.forEach { tracker in
            let trackerStore = TrackerStore(context: context)
            trackerStore.createTracker(from: tracker)
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Read
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            return categoriesCoreData.map { coreData in
                TrackerCategory(
                    title: coreData.title ?? "",
                    trackers: (coreData.trackers as? Set<TrackerCoreData>)?.compactMap { trackerCoreData in
                        Tracker(
                            id: trackerCoreData.id ?? UUID(),
                            name: trackerCoreData.name ?? "",
                            color: UIColor(hex: trackerCoreData.color ?? "#FFFFFF"),
                            emoji: trackerCoreData.emoji ?? "",
                            schedule: (trackerCoreData.schedule as? Set<WeekdayCoreData>)?.compactMap {
                                WeekdayStore(context: context).weekday(from: $0)
                            } ?? []
                        )
                    } ?? []
                )
            }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
}
