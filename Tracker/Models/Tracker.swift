//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.10.2024.
//

import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
}

enum Weekday: String {
    case monday = "пн."
    case tuesday = "вт."
    case wednesday = "ср."
    case thursday = "чт."
    case friday = "пт."
    case saturday = "сб."
    case sunday = "вс."
}
