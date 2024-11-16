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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.trackerTypeSelectionVcHabit, for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onTrackerTypeSelected: ((TrackerType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ProjectColors.white
        
        navigationController?.navigationBar.isHidden = true
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
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
        let habitVC = HabitViewController()
        navigationController?.pushViewController(habitVC, animated: true)
        print("Переход на экран создания Привычки")
    }
    
    @objc private func irregularEventButtonTapped() {
        guard navigationController?.topViewController == self else { return }
        let irregularEventVC = IrregularEventViewController()
        navigationController?.pushViewController(irregularEventVC, animated: true)
        print("Переход на экран создания Нерегулярного события")
    }
}
