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
        print("🟢 Добавляем запись: трекер ID \(trackerId), дата \(date)")
        
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.trackerID = trackerId
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        do {
            let trackers = try context.fetch(fetchRequest)
            if let tracker = trackers.first {
                record.tracker = tracker
                CoreDataStack.shared.saveContext()
                print("✅ Запись добавлена для трекера \(tracker.name ?? "Без имени")")
            } else {
                print("⚠️ Трекер с ID \(trackerId) не найден")
            }
        } catch {
            print("❌ Ошибка при добавлении записи: \(error)")
        }
        
        CoreDataStack.shared.saveContext()
    }
    
    func fetchRecords(for trackerId: UUID) -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerId as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).compactMap { $0.date }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func deleteRecord(for trackerId: UUID, on date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
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
