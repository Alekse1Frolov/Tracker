//
//  WeekdayStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import Foundation
import CoreData

final class WeekdayStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<WeekdayCoreData>?
    
    var didChangeContent: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        super.init()
    }
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<WeekdayCoreData> = WeekdayCoreData.fetchRequest()
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
    func createWeekday(from weekday: Weekday) -> WeekdayCoreData? {
        let weekdayCoreData = WeekdayCoreData(context: context)
        weekdayCoreData.name = weekdayName(from: weekday)
        CoreDataStack.shared.saveContext()
        return weekdayCoreData
    }
    
    func fetchWeekdayCoreData(for weekday: Weekday) -> WeekdayCoreData? {
        let fetchRequest: NSFetchRequest<WeekdayCoreData> = WeekdayCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", weekdayName(from: weekday))
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching WeekdayCoreData: \(error)")
            return nil
        }
    }
    
    // MARK: - Helpers
    func weekday(from coreData: WeekdayCoreData) -> Weekday? {
        guard let name = coreData.name else { return nil }
        return Weekday.allCases.first { weekdayName(from: $0) == name }
    }
    
    private func weekdayName(from weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}
