//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.12.2024.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    var pageIndex: Int = 0
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = Asset.ypBlack.color
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = Asset.ypBlack.color
        button.setTitleColor(Asset.ypWhite.color, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Asset.ypWhite.color
        setupView()
    }
    
    private func setupView() {
        
        [imageView, titleLabel, skipButton].forEach { element in
            view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: view.frame.height / 2),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -16),
            
            skipButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -50),
            skipButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20),
            skipButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        if pageIndex == 0 {
            titleLabel.text = "Отслеживайте\nтолько то, что\nхотите"
            imageView.image = UIImage(named: "BlueBackground")
        } else if pageIndex == 1 {
            titleLabel.text = "Даже если это\nне литры воды \nи йога"
            imageView.image = UIImage(named: "RedBackground")
        }
    }
    
    @objc private func skipOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            let trackersVC = TrackersViewController()
            let navigationController = UINavigationController(rootViewController: trackersVC)
            sceneDelegate.window?.rootViewController = navigationController
        }
    }
}
