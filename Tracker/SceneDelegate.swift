//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.07.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            let tabBarController = TabBarViewController()
            window?.rootViewController = tabBarController
        } else {
            let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
                    window?.rootViewController = onboardingViewController
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataStack.shared.saveContext()
    }
}

