//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 04.11.2024.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.trackerTypeSelectionVcTitle
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.tintColor = ProjectColors.black
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.trackerTypeSelectionVcHabit, for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.trackerTypeSelectionVcIrregularEvent, for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onTrackerTypeSelected: ((TrackerType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.backgroundColor = ProjectColors.white
        
        [titleLabel, habitButton, irregularEventButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            
            // tileLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // habbitButton constraints
            habitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // irregularEventButton constraints
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            irregularEventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor)
        ])
    }
    
    @objc private func habitButtonTapped() {
        guard navigationController?.topViewController == self else { return }
        let habitVC = EventViewController(trackerType: .habit)
        navigationController?.pushViewController(habitVC, animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        guard navigationController?.topViewController == self else { return }
        let irregularEventVC = EventViewController(trackerType: .irregularEvent)
        navigationController?.pushViewController(irregularEventVC, animated: true)
    }
}
