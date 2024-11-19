//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 09.11.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    private var selectedDays: [Bool]
    
    var onDaysSelected: (([Weekday]) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.scheduleVcTitle
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.tintColor = ProjectColors.black
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.scheduleVcReadyButtonTitle, for: .normal)
        button.backgroundColor = ProjectColors.black
        button.setTitleColor(ProjectColors.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(selectedDays: [Bool]) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupLayout()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
    }
    
    private func setupLayout() {
        view.backgroundColor = ProjectColors.white
        
        [titleLabel, tableView, readyButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            
            // titleLabel constraint
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // tableView constraint
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: 39),
            
            // readyButton constraint
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    @objc private func readyButtonTapped() {
        let selectedDaysNames = MockData.days.enumerated().compactMap { index, _ in
            selectedDays[index] ? Weekday(rawValue: index + 1) : nil
        }
        
        onDaysSelected?(selectedDaysNames)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        selectedDays[sender.tag] = sender.isOn
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        MockData.days.count
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = MockData.days[indexPath.row]
        let isSelected = selectedDays[indexPath.row]
        
        cell.configure(
            with: day,
            isSelected: isSelected,
            tag: indexPath.row,
            target: self,
            action: #selector(switchToggled(_:)))
        cell.backgroundColor = ProjectColors.lightGray?.withAlphaComponent(0.3)
        
        return cell
    }
}
