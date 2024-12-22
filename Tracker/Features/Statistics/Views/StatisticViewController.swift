//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.08.2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.statisticPlaceholder.image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Asset.ypLightGray.color
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    private var statistics: [Statistic] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTableView()
        calculateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func calculateStatistics() {
            let bestPeriod = calculateBestPeriod()
            let perfectDays = calculatePerfectDays()
            let completedTrackers = calculateCompletedTrackers()
            let averageValue = calculateAverageValue()

            statistics = [
                Statistic(title: "Лучший период", value: bestPeriod),
                Statistic(title: "Идеальные дни", value: perfectDays),
                Statistic(title: "Трекеров завершено", value: completedTrackers),
                Statistic(title: "Среднее значение", value: averageValue)
            ]

            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    
    private func calculateBestPeriod() -> Int {
            // TO DO: Подсчёт лучшего периода
            return 0
        }

        private func calculatePerfectDays() -> Int {
            // TO DO: подсчёта идеальных дней
            return 0
        }

        private func calculateCompletedTrackers() -> Int {
            // TO DO: подсчёт завершённых трекеров
            return 0
        }

        private func calculateAverageValue() -> Int {
            // TO DO: подсчёт среднего значения
            return 0
        }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: "StatisticTableViewCell")
    }
    
    private func updatePlaceholderVisibility() {
            let hasData = statistics.contains { $0.value > 0 }
            placeholderImageView.isHidden = hasData
            placeholderLabel.isHidden = hasData
            tableView.isHidden = !hasData
        }
    
    private func setupLayout() {
        view.backgroundColor = Asset.ypWhite.color
        
        [titleLabel, placeholderImageView, placeholderLabel, tableView].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // placeholderImageView constraints
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // placeholderLabel constraints
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension StatisticViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        statistics.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? StatisticTableViewCell else {
            return UITableViewCell()
        }

        let statistic = statistics[indexPath.row]
        cell.setTitle(text: statistic.title)
        cell.setCount(count: statistic.value)
        return cell
    }
}

extension StatisticViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        90
    }
}
