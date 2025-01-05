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
        if fetchRecord(for: trackerId, on: date) != nil {
            print("Запись завершения уже существует для трекера \(trackerId) на дату \(date)")
            return
        }
        
        let record = TrackerRecordCoreData(context: context)
        record.date = date.strippedTime()
        record.trackerID = trackerId
        
        if let tracker = fetchTracker(byID: trackerId) {
            record.tracker = tracker
            CoreDataStack.shared.saveContext()
            print("Добавлена запись завершения для трекера \(trackerId) на дату \(date)")
        } else {
            print("Ошибка: не удалось найти трекер с ID \(trackerId)")
        }
    }
    
    func fetchAllRecords() -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let records = try context.fetch(fetchRequest)
            print("Загружены все записи завершений: \(records)")
            return records
        } catch {
            print("Ошибка загрузки всех записей завершений: \(error)")
            return []
        }
    }
    
    func fetchRecords(for trackerID: UUID) -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            let dates = records.compactMap { $0.date }
            print("Завершённые даты для трекера \(trackerID): \(dates)")
            return dates
        } catch {
            print("Ошибка загрузки записей завершений: \(error)")
            return []
        }
    }
    
    func fetchCompletedTrackerIDs(for date: Date) -> [UUID] {
        let strippedDate = date.strippedTime() ?? date
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", strippedDate as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            let trackerIDs = records.compactMap { $0.trackerID }
            print("Завершённые трекеры на дату \(date): \(trackerIDs)")
            return trackerIDs
        } catch {
            print("Ошибка загрузки завершённых трекеров: \(error)")
            return []
        }
    }
    
    func deleteRecord(for trackerId: UUID, on date: Date) {
        let strippedDate = date.strippedTime() ?? date
        if let record = fetchRecord(for: trackerId, on: strippedDate) {
            context.delete(record)
            CoreDataStack.shared.saveContext()
            print("Удалена запись завершения для трекера \(trackerId) на дату \(strippedDate)")
        } else {
            print("Запись завершения для трекера \(trackerId) на дату \(strippedDate) не найдена")
        }
    }
    
    private func fetchRecord(for trackerId: UUID, on date: Date) -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerId as CVarArg, date as NSDate)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при поиске записи завершения: \(error)")
            return nil
        }
    }
    
    private func fetchTracker(byID id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let tracker = try context.fetch(fetchRequest).first
            if tracker == nil {
                print("Не найден трекер с ID \(id)")
            }
            return tracker
        } catch {
            print("Ошибка загрузки трекера с ID \(id): \(error)")
            return nil
        }
    }
}
