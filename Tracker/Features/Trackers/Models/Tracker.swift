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
    let color: String
    let emoji: String
    let schedule: [Weekday]
    let date: Date
    let category: String
    let order: Int
    let isPinned: Bool
    
    init(
        id: UUID,
        name: String,
        color: String,
        emoji: String,
        schedule: [Weekday],
        date: Date,
        category: String,
        order: Int,
        isPinned: Bool
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.date = date
        self.category = category
        self.order = order
        self.isPinned = isPinned
    }
    
    init(coreDataTracker: TrackerCoreData) {
        self.id = coreDataTracker.id ?? UUID()
        self.name = coreDataTracker.name ?? "Без названия"
        self.color = coreDataTracker.color ?? "#FFFFFF"
        self.emoji = coreDataTracker.emoji ?? "❓"
        self.date = coreDataTracker.date ?? Date()
        self.category = coreDataTracker.category?.title ?? "Без категории"
        self.order = Int(coreDataTracker.order)
        self.isPinned = coreDataTracker.isPinned
        
        if let coreDataSchedule = coreDataTracker.schedule as? Set<WeekdayCoreData> {
            self.schedule = coreDataSchedule.compactMap { Weekday(rawValue: Int($0.number)) }
        } else {
            self.schedule = []
        }
    }
}
