//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    var didChangeContent: (() -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    convenience init(defaultContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: defaultContext)
    }

    func weekday(from coreData: WeekdayCoreData) -> Weekday? {
            guard let name = coreData.name else { return nil }
            return Weekday.allCases.first { $0.abbreviation == name }
        }
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
    
    func addRecord(for trackerId: UUID, on date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date

        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        do {
            let trackers = try context.fetch(fetchRequest)
            if let tracker = trackers.first {
                record.tracker = tracker
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Error adding record: \(error)")
        }
    }
    
    func fetchRecords(for trackerId: UUID) -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            return records.compactMap { $0.date }
        } catch {
            print("Error fetching records: \(error)")
            return []
        }
    }
    
    func deleteRecord(for trackerId: UUID, on date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            CoreDataStack.shared.saveContext()
        } catch {
            print("Error deleting record: \(error)")
        }
    }
}
