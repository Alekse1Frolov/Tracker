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
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.tintColor = ProjectColors.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let habbitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(habbitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ProjectColors.white
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(habbitButton)
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            
            // tileLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // habbitButton constraints
            habbitButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            habbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habbitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habbitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // irregularEventButton constraints
            irregularEventButton.topAnchor.constraint(equalTo: habbitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: habbitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habbitButton.trailingAnchor),
            irregularEventButton.heightAnchor.constraint(equalTo: habbitButton.heightAnchor)
        ])
    }
    
    @objc private func habbitButtonTapped() {
        let habitVC = HabitViewController()
        habitVC.modalPresentationStyle = .pageSheet
        present(habitVC, animated: true, completion: nil)
        print("Переход на экран создания Привычки")
    }
    
    @objc private func irregularEventButtonTapped() {
        let irregularEventVC = IrregularEventViewController()
        irregularEventVC.modalPresentationStyle = .pageSheet
        present(irregularEventVC, animated: true, completion: nil)
        print("Переход на экран создания Нерегулярного события")
    }
}
