//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Aleksei Frolov on 21.12.2024.
//

import Foundation

enum TrackerFilter {
    case allTrackers
    case today
    case completed
    case incomplete
    
    var displayName: String {
        switch self {
        case .allTrackers: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершённые"
        case .incomplete: return "Незавершённые"
        }
    }
}
