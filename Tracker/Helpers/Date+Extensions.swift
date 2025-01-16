//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Aleksei Frolov on 05.01.2025.
//

import Foundation

extension Date {
    func strippedTime() -> Date? {
        return Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month, .day],
                                                  from: self)
        )
    }
}
