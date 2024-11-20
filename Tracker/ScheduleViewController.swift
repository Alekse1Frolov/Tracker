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
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.scheduleVcTitle
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.tintColor = Asset.ypBlack.color
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.scheduleVcReadyButtonTitle, for: .normal)
        button.backgroundColor = Asset.ypBlack.color
        button.setTitleColor(Asset.ypWhite.color, for: .normal)
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
        
        setupScrollView()
        setupLayout()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                tableView.heightAnchor.constraint(equalToConstant: 525)
            ])
    }
    
    private func setupLayout() {
        view.backgroundColor = Asset.ypWhite.color
        
        [titleLabel, scrollView, readyButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            // titleLabel constraint
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // tableView constraint
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -24),
            
            // readyButton constraint
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupScrollView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // contentView constraint
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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
        cell.backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
        
        return cell
    }
}
