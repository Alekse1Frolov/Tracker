//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.10.2024.
//

import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.trackerId == rhs.trackerId && lhs.date == rhs.date
    }
    
    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
    
    init(coreDataRecord: TrackerRecordCoreData) {
        self.trackerId = coreDataRecord.trackerID ?? UUID()
        self.date = coreDataRecord.date ?? Date()
    }
}
