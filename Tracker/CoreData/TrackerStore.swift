//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksei Frolov on 26.11.2024.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let pinnedCategoryTitle = "Закреплённые"
    public private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var onDataChange: (() -> Void)?
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
        super.init()
        
        ensurePinnedCategoryExists()
    }
    
    func setupFetchedResultsController(
        predicate: NSPredicate? = nil
    ) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "order", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            onDataChange?()
        } catch {
            print("Ошибка настройки FetchedResultsController: \(error)")
        }
    }
    
    func createTracker(from tracker: Tracker) {
        print("Создаём трекер: \(tracker.name), ID: \(tracker.id), Тип: \(tracker.schedule.isEmpty ? ".irregularEvent" : ".habit"), Расписание: \(tracker.schedule), Категория: \(tracker.category)")
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.date = tracker.date
        trackerCoreData.isPinned = tracker.isPinned
        
        if let category = fetchCategory(byTitle: tracker.category) {
            trackerCoreData.category = category
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = tracker.category
            trackerCoreData.category = newCategory
        }
        
        tracker.schedule.forEach { weekday in
            let weekdayCoreData = WeekdayCoreData(context: context)
            weekdayCoreData.number = Int16(weekday.rawValue)
            weekdayCoreData.name = weekday.displayName
            trackerCoreData.addToSchedule(weekdayCoreData)
        }
        
        trackerCoreData.type = tracker.schedule.isEmpty
        ? TrackerType.irregularEvent.rawValue
        : TrackerType.habit.rawValue
        
        print("Создан трекер: \(tracker.name), ID: \(tracker.id), Тип: \(tracker.type), Расписание: \(tracker.schedule), Дата: \(tracker.date) Категория: \(tracker.category)")
        saveContext()
    }
    
    func fetchTrackersIfNeeded() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка загрузки трекеров: \(error)")
        }
    }
    
    func fetchTracker(byID id: UUID) -> Tracker? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let trackerCoreData = try? context.fetch(fetchRequest).first {
            return Tracker(coreDataTracker: trackerCoreData)
        }
        return nil
    }
    
    func fetchTrackers(predicate: NSPredicate?) -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = predicate
        
        do {
            let fetchedResults = try context.fetch(request)
            let trackers = fetchedResults.compactMap { Tracker(coreDataTracker: $0) }
            
            print("Загруженные трекеры с предикатом \(String(describing: predicate)):")
            trackers.forEach { tracker in
                print("- \(tracker.name), Тип: \(tracker.type), Расписание: \(tracker.schedule), Дата: \(String(describing: tracker.date))")
            }
            
            return trackers
        } catch {
            print("Ошибка загрузки трекеров: \(error)")
            return []
        }
    }
    
    func fetchCompletedTrackersSet(for date: Date) -> Set<UUID> {
        let currentDateOnly = Calendar.current.startOfDay(for: date)
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", currentDateOnly as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            let trackerIDs = records.compactMap { $0.trackerID }
            print("Завершённые трекеры на дату \(currentDateOnly): \(trackerIDs)")
            return Set(trackerIDs)
        } catch {
            print("Ошибка загрузки завершённых трекеров: \(error)")
            return []
        }
    }
    
    func updateTracker(
        _ tracker: Tracker,
        name: String,
        color: String,
        emoji: String,
        schedule: [Weekday],
        category: String
    ) {
        print("Обновляем трекер \(tracker.name): Новое расписание \(schedule), Новая дата \(tracker.date)")
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                trackerCoreData.name = name
                trackerCoreData.color = color
                trackerCoreData.emoji = emoji
                
                trackerCoreData.schedule?.forEach { context.delete($0 as! NSManagedObject) }
                schedule.forEach { weekday in
                    let weekdayCoreData = WeekdayCoreData(context: context)
                    weekdayCoreData.number = Int16(weekday.rawValue)
                    weekdayCoreData.name = weekday.displayName
                    trackerCoreData.addToSchedule(weekdayCoreData)
                }
                
                if let categoryCoreData = fetchCategory(byTitle: category) {
                    trackerCoreData.category = categoryCoreData
                } else {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = category
                    trackerCoreData.category = newCategory
                }
                
                saveContext()
            }
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
    
    func deleteTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                context.delete(tracker)
                saveContext()
            }
        } catch {
            print("Ошибка удаления трекера: \(error)")
        }
    }
    
    // MARK: - Filtering Methods
    func fetchTrackersForCurrentDate(_ date: Date) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        let correctedWeekday = (weekday + 5) % 7 + 1 // Преобразование в формат enum Weekday
        
        print("Фильтрация трекеров на дату: \(date), День недели: \(correctedWeekday)")
        
        let predicateHabit = NSPredicate(format: "ANY schedule.number == %d", correctedWeekday)
        let predicateIrregular = NSPredicate(format: "date == %@", date as NSDate)
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateHabit, predicateIrregular])
        
        print("Сформированный предикат: \(compoundPredicate)")
        
        return fetchTrackers(with: compoundPredicate)
    }
    
    func fetchCompletedTrackers(for date: Date) -> [TrackerCategory] {
        let recordStore = TrackerRecordStore(context: context)
        let completedTrackerIDs = Set(recordStore.fetchCompletedTrackerIDs(for: date))
        
        let completedTrackersPredicate = NSPredicate(format: "id IN %@", completedTrackerIDs)
        let completedTrackers = fetchTrackers(with: completedTrackersPredicate).flatMap { $0.trackers }
        
        print("Завершённые трекеры: \(completedTrackers.map { $0.name })")
        return categorizeTrackers(completedTrackers)
    }
    
    func fetchCompletionCount(for trackerID: UUID) -> Int {
        let recordStore = TrackerRecordStore(context: CoreDataStack.shared.mainContext)
        let completedDates = recordStore.fetchRecords(for: trackerID)
        return completedDates.count
    }
    
    func fetchIncompleteTrackers(for date: Date) -> [TrackerCategory] {
        let recordStore = TrackerRecordStore(context: context)
        let completedTrackerIDs = Set(recordStore.fetchCompletedTrackerIDs(for: date))
        
        let allTrackersPredicate = currentPredicate(for: date)
        let allTrackers = fetchTrackers(with: allTrackersPredicate).flatMap { $0.trackers }
        
        let incompleteTrackers = allTrackers.filter { !completedTrackerIDs.contains($0.id) }
        
        print("Незавершённые трекеры: \(incompleteTrackers.map { $0.name })")
        return categorizeTrackers(incompleteTrackers)
    }
    
    private func fetchTrackers(with predicate: NSPredicate) -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let trackers = try context.fetch(fetchRequest)
            print("Трекеры, загруженные с предикатом \(predicate):")
            trackers.forEach { tracker in
                let schedule = (tracker.schedule as? Set<WeekdayCoreData>)?.compactMap { $0.number }
                print("- \(tracker.name ?? "Без названия"), Дни недели: \(schedule ?? []), Дата: \(tracker.date ?? Date.distantPast)")
            }
            return categorizeTrackers(trackers.map { Tracker(coreDataTracker: $0) })
        } catch {
            print("Ошибка при фильтрации трекеров: \(error)")
            return []
        }
    }
    
    // MARK: - Helpers
    private func categorizeTrackers(_ trackers: [Tracker]) -> [TrackerCategory] {
        var categories: [String: [Tracker]] = [:]
        
        for tracker in trackers {
            let categoryTitle = tracker.category
            categories[categoryTitle, default: []].append(tracker)
        }
        
        return categories.map { TrackerCategory(title: $0.key, trackers: $0.value) }
    }
    
    private func fetchCategory(byTitle title: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при получении категории: \(error)")
            return nil
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
            onDataChange?()
        } catch {
            print("Ошибка сохранения контекста: \(error)")
        }
    }
    
    private func ensurePinnedCategoryExists() {
        if fetchCategory(byTitle: pinnedCategoryTitle) == nil {
            let category = TrackerCategoryCoreData(context: context)
            category.title = pinnedCategoryTitle
            saveContext()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Данные изменены. Обновляем UI.")
        onDataChange?()
    }
}

extension TrackerStore {
    func pinTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                tracker.isPinned = true
                try context.save()
                onDataChange?()
            }
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    func unpinTracker(by id: UUID) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                tracker.isPinned = false
                try context.save()
                onDataChange?()
            }
        } catch {
            print("Ошибка при откреплении трекера: \(error)")
        }
    }
    
    private func fetchPinnedCategory() -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", pinnedCategoryTitle)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Ошибка при получении категории \"Закреплённые\": \(error)")
            return nil
        }
    }
    
    func fetchCategory(for trackerID: UUID) -> String? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        do {
            if let tracker = try context.fetch(fetchRequest).first {
                return tracker.category?.title
            }
        } catch {
            print("Ошибка при загрузке категории для трекера: \(error)")
        }
        return nil
    }
    
    func currentPredicate(for date: Date) -> NSPredicate {
        let selectedDate = Calendar.current.startOfDay(for: date)
        print("Фильтрация трекеров на дату: \(selectedDate) (обнулённая дата)")
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
        
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let correctedWeekday = (weekdayIndex + 5) % 7 + 1
        
        let habitPredicate = NSPredicate(
            format: "type == %@ AND ANY schedule.number == %d",
            TrackerType.habit.rawValue, correctedWeekday
        )
        let irregularEventPredicate = NSPredicate(
            format: "type == %@ AND date >= %@ AND date < %@",
            TrackerType.irregularEvent.rawValue,
            selectedDate as NSDate,
            nextDay as NSDate
        )
        
        let compoundPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [habitPredicate, irregularEventPredicate]
        )
        print("Формируем предикат: \(compoundPredicate)")
        
        return compoundPredicate
    }
    
    func completedTrackersPredicate(for date: Date) -> NSPredicate {
        let completedTrackerIDs = fetchCompletedTrackersSet(for: date)
        return NSPredicate(format: "id IN %@", completedTrackerIDs)
    }
    
    func incompleteTrackersPredicate(for date: Date) -> NSPredicate {
        let completedTrackerIDs = fetchCompletedTrackersSet(for: date)
        let allTrackersPredicate = currentPredicate(for: date)
        let incompletePredicate = NSPredicate(format: "NOT (id IN %@)", completedTrackerIDs)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [allTrackersPredicate, incompletePredicate])
    }
}
