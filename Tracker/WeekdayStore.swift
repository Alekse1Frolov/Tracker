//
//  WeekdayStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData

final class WeekdayStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }
    
    func createWeekday(from weekday: Weekday) -> WeekdayCoreData? {
        print("🟢 Создаём день недели: \(weekday.displayName)")
        let weekdayCoreData = WeekdayCoreData(context: context)
        weekdayCoreData.name = weekday.displayName
        weekdayCoreData.number = Int16(weekday.rawValue)
        
        CoreDataStack.shared.saveContext()
        print("✅ День недели \(weekday.displayName) сохранён.")
        return weekdayCoreData
    }

    
    func fetchWeekday(for weekday: Weekday) -> WeekdayCoreData? {
        let fetchRequest: NSFetchRequest<WeekdayCoreData> = WeekdayCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "number == %d", weekday.rawValue)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch weekday: \(error)")
            return nil
        }
    }
}
