//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.10.2024.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    let type: TrackerType
    
    init(title: String, trackers: [Tracker], type: TrackerType) {
        self.title = title
        self.trackers = trackers
        self.type = type
    }
    
    init(coreDataCategory: TrackerCategoryCoreData) {
        self.title = coreDataCategory.title ?? "Unnamed"
        self.trackers = (coreDataCategory.trackers as? Set<TrackerCoreData>)?
            .compactMap { Tracker(coreDataTracker: $0) } ?? []
        self.type = trackers.allSatisfy { !$0.schedule.isEmpty } ? .habit : .irregularEvent
    }

}
