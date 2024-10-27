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
        view.backgroundColor = ProjectColors.white
        
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TrackerTabImage"), selectedImage: nil)
        
        let statisticVC = UINavigationController(rootViewController: StatisticViewController())
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "StatTabImage"), selectedImage: nil)
        
        viewControllers = [trackersVC, statisticVC]
        
        tabBar.tintColor = ProjectColors.blue
        tabBar.unselectedItemTintColor = ProjectColors.gray
        tabBar.backgroundColor = ProjectColors.white
    }
}
