//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.12.2024.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    private var pages: [OnboardingPageViewController] = []
    private var currentPageIndex: Int = 0
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = Asset.ypBlack.color
        pageControl.pageIndicatorTintColor = Asset.ypLightGray.color
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        setupPages()
        setupPageControl()
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        updatePageControl(for: 0)
    }
    
    private func setupPages() {
        let page1 = OnboardingPageViewController()
        page1.pageIndex = 0
        let page2 = OnboardingPageViewController()
        page2.pageIndex = 1
        
        pages = [page1, page2]
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.numberOfPages = pages.count
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updatePageControl(for pageIndex: Int) {
        guard pageIndex >= 0, pageIndex < pages.count else { return }
        pageControl.currentPage = pageIndex
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
        if let nextPage = viewControllers.first as? OnboardingPageViewController {
            currentPageIndex = nextPage.pageIndex
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            updatePageControl(for: currentPageIndex)
        }
    }
}
