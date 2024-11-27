//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.10.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let category: String
    let completionCount: Int
    
    init(
        id: UUID,
        name: String,
        color: UIColor,
        emoji: String,
        schedule: [Weekday],
        category: String
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.category = category
        self.completionCount = 0
    }
    
    init(coreDataTracker: TrackerCoreData, recordStore: TrackerRecordStore) {
        self.id = coreDataTracker.id ?? UUID()
        self.name = coreDataTracker.name ?? ""
        self.color = UIColor(hex: coreDataTracker.color ?? "#FFFFFF")
        self.emoji = coreDataTracker.emoji ?? ""
        self.schedule = (coreDataTracker.schedule as? Set<WeekdayCoreData>)?.compactMap {
            recordStore.weekday(from: $0)
        } ?? []
        self.category = coreDataTracker.category?.title ?? "Без категории"
        self.completionCount = recordStore.fetchRecords(for: id).count
    }
}
