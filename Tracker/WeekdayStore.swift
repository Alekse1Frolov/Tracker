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
    
    func fetchWeekday(for weekday: Weekday) -> WeekdayCoreData? {
        let fetchRequest: NSFetchRequest<WeekdayCoreData> = WeekdayCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "number == %d", weekday.rawValue)
        return try? context.fetch(fetchRequest).first
    }
}
