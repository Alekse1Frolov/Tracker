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
    
    // MARK: Light Theme
    
    func testTrackersNavigationBarLight() throws {
        
        let vc = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        vc.loadViewIfNeeded()
        navigationController.loadViewIfNeeded()
        
        let navigationBar = navigationController.navigationBar
        assertSnapshots(
            of: navigationBar,
            as: [.image(traits: .init(userInterfaceStyle: .light))],
            record: false
        )
    }
    
    func testTabBarViewControllerLight() throws {
        
        let tb = TabBarViewController()
        
        tb.loadViewIfNeeded()
        
        let tabBar = tb.tabBar
        
        assertSnapshots(
            of: tabBar,
            as: [.image(traits: .init(userInterfaceStyle: .light))],
            record: false
        )
    }
    
    func testTrackersViewControllerInitialPlaceholderLight() throws {
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        
        let vc = TrackersViewController()
        
        vc.loadViewIfNeeded()
        
        assertSnapshots(
            of: vc,
            as: [.image(traits: .init(userInterfaceStyle: .light))],
            record: false
        )
    }
    
    func testIncompletedTrackerInTrackersCollectionLight() throws {
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
        
        assertSnapshots(
            of: cell,
            as: [.image(traits: .init(userInterfaceStyle: .light))],
            record: false
        )
    }
    
    func testCompletedTrackerInTrackersCollectionLight() throws {
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
        
        assertSnapshots(
            of: cell,
            as: [.image(traits: .init(userInterfaceStyle: .light))],
            record: false
        )
    }
    
    // MARK: Dark Theme
    
    func testTrackersNavigationBarDark() throws {
        
        let vc = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        vc.loadViewIfNeeded()
        navigationController.loadViewIfNeeded()
        
        let navigationBar = navigationController.navigationBar
        assertSnapshots(
            of: navigationBar,
            as: [.image(traits: .init(userInterfaceStyle: .dark))],
            record: false
        )
    }
    
    func testTabBarViewControllerDark() throws {
        
        let tb = TabBarViewController()
        
        tb.loadViewIfNeeded()
        
        let tabBar = tb.tabBar
        
        assertSnapshots(
            of: tabBar,
            as: [.image(traits: .init(userInterfaceStyle: .dark))],
            record: false
        )
    }
    
    func testTrackersViewControllerInitialPlaceholderDark() throws {
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        
        let vc = TrackersViewController()
        
        vc.loadViewIfNeeded()
        
        assertSnapshots(
            of: vc,
            as: [.image(traits: .init(userInterfaceStyle: .dark))],
            record: false
        )
    }
    
    func testIncompletedTrackerInTrackersCollectionDark() throws {
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
        
        assertSnapshots(
            of: cell,
            as: [.image(traits: .init(userInterfaceStyle: .dark))],
            record: false
        )
    }
    
    func testCompletedTrackerInTrackersCollectionDark() throws {
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
        
        assertSnapshots(
            of: cell,
            as: [.image(traits: .init(userInterfaceStyle: .dark))],
            record: false
        )
    }
}
