//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.08.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        view.backgroundColor = Asset.ypWhite.color
        
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "TabBar"),
            image: Asset.trackerTabImage.image,
            selectedImage: nil
        )
        
        let trackerStore = TrackerStore(context: CoreDataStack.shared.mainContext)
        let statisticVC = UINavigationController(rootViewController: StatisticViewController(trackerStore: trackerStore))
        statisticVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic", comment: "TabBar"),
            image: Asset.statTabImage.image,
            selectedImage: nil
        )
        
        viewControllers = [trackersVC, statisticVC]
        
        tabBar.tintColor = Asset.ypBlue.color
        tabBar.unselectedItemTintColor = Asset.ypGray.color
        tabBar.backgroundColor = Asset.ypWhite.color
    }
}
