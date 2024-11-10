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
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
