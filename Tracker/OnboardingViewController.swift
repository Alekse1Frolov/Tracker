//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.12.2024.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    private var pages: [OnboardingPageViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        let page1 = OnboardingPageViewController()
        page1.pageIndex = 0
        let page2 = OnboardingPageViewController()
        page2.pageIndex = 1
        
        pages = [page1, page2]
        
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController as! OnboardingPageViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo viewControllers: [UIViewController]
        ) {
            guard viewControllers.first is OnboardingPageViewController else { return }
        }
}
