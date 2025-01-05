//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Aleksei Frolov on 05.01.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersNavigationBar() throws {
        
        let vc = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        vc.loadViewIfNeeded()
        navigationController.loadViewIfNeeded()
        
        let navigationBar = navigationController.navigationBar
        assertSnapshot(
            of: navigationBar,
            as: .image,
            record: false
        )
    }
    
    func testTabBarViewController() throws {
        
        let tb = TabBarViewController()
        
        tb.loadViewIfNeeded()
        
        let tabBar = tb.tabBar
        
        assertSnapshot(
            of: tabBar,
            as: .image,
            record: false
        )
    }
    
    func testTrackersViewControllerInitialPlaceholder() throws {
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        
        let vc = TrackersViewController()
        
        vc.loadViewIfNeeded()
        
        assertSnapshot(
            of: vc,
            as: .image,
            record: false
        )
    }
    
    func testIncompletedTrackerInTrackersCollection() throws {
        let cell = TrackerCell(frame: CGRect(x: 0, y: 0, width: 167, height: 132))
        let tracker = Tracker(
            id: UUID(),
            name: "SnapshotTest1",
            color: "F9D4D4",
            emoji: "🐶",
            type: .habit,
            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
            date: Date(),
            category: "Cat",
            order: 0,
            isPinned: false
        )
        
        cell.configure(with: tracker, completed: false, completionCount: 0, isPinned: false)
        
        assertSnapshot(
            of: cell,
            as: .image,
            record: false
        )
    }
    
    func testCompletedTrackerInTrackersCollection() throws {
        let cell = TrackerCell(frame: CGRect(x: 0, y: 0, width: 167, height: 132))
        let tracker = Tracker(
            id: UUID(),
            name: "SnapshotTest2",
            color: "E66DD4",
            emoji: "😻",
            type: .irregularEvent,
            schedule: [],
            date: Date(),
            category: "Закреплённые",
            order: 0,
            isPinned: true
        )
        
        cell.configure(with: tracker, completed: true, completionCount: 1, isPinned: true)
        
        assertSnapshot(
            of: cell,
            as: .image,
            record: false
        )
    }
}
