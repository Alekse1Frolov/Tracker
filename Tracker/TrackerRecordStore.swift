//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    func addRecord(for trackerId: UUID, on date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.trackerID = trackerId
        
        if let tracker = fetchTracker(byID: trackerId) {
            record.tracker = tracker
            CoreDataStack.shared.saveContext()
        }
    }
    
    func fetchAllRecords() -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func fetchRecords(for trackerId: UUID) -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerId as CVarArg)
        return (try? context.fetch(fetchRequest).compactMap { $0.date }) ?? []
    }
    
    func deleteRecord(for trackerId: UUID, on date: Date) {
            let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
            
            if let records = try? context.fetch(fetchRequest) {
                records.forEach { context.delete($0) }
                CoreDataStack.shared.saveContext()
            }
        }
    
    private func fetchTracker(byID id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(fetchRequest).first
    }
}
