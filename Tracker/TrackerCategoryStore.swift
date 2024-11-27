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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeContent?()
    }
    
    // MARK: - Create
    func createCategory(from category: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        category.trackers.forEach { tracker in
            let trackerStore = TrackerStore(context: context)
            trackerStore.createTracker(from: tracker)
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Read
    func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", title)
            do {
                return try context.fetch(fetchRequest).first
            } catch {
                print("Ошибка при загрузке категории \(title): \(error)")
                return nil
            }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            let recordStore = TrackerRecordStore(context: context)
            return categoriesCoreData.map { coreData in
                TrackerCategory(
                    title: coreData.title ?? "",
                    trackers: (coreData.trackers as? Set<TrackerCoreData>)?.compactMap {
                        Tracker(coreDataTracker: $0, recordStore: recordStore)
                    } ?? []
                )
            }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
}
