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
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
    
    init(coreDataCategory: TrackerCategoryCoreData) {
        self.title = coreDataCategory.title ?? "Unnamed"
        self.trackers = (coreDataCategory.trackers as? Set<TrackerCoreData>)?
            .compactMap { Tracker(coreDataTracker: $0) } ?? []
    }

}
