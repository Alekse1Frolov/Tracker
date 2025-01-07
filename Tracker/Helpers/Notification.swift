//
//  Notification.swift
//  Tracker
//
//  Created by Aleksei Frolov on 13.11.2024.
//

import Foundation

extension Notification.Name {
    static let createdTracker = Notification.Name("createdTracker")
    static let updatedTracker = Notification.Name("updatedTracker")
    static let completedTrackersDidUpdate = Notification.Name("completedTrackersDidUpdate")
}
