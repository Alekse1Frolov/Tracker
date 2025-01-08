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
        label.text = Constants.statisticViewControllerTitle
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
        label.text = Constants.statisticVCPlaceholderText
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
    
    private let trackerStore: TrackerStore
    private var statistics: [Statistic] = []
    private var placeholderPresenter: PlaceholderPresenter?
    
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTableView()
        
        placeholderPresenter = PlaceholderPresenter(
            imageView: placeholderImageView,
            label: placeholderLabel
        )
        
        calculateStatistics()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCompletedTrackersDidUpdate),
            name: .completedTrackersDidUpdate,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .completedTrackersDidUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func calculateStatistics() {
        let completedTrackers = calculateCompletedTrackers()
        
        statistics = [
            Statistic(
                title: Constants.statisticVCCompletedHabitsOption,
                value: completedTrackers
            )
        ]
        
        updatePlaceholderVisibility()
        tableView.reloadData()
    }
    
    private func calculateCompletedTrackers() -> Int {
        let recordStore = TrackerRecordStore(context: trackerStore.managedContext)
        let completedRecords = recordStore.fetchAllRecords()
        
        let habitTrackerIDs = trackerStore.fetchTrackers(predicate: NSPredicate(format: "type == %@", TrackerType.habit.rawValue)).map { $0.id }
        let completedHabitRecords = completedRecords.filter { habitTrackerIDs.contains($0.trackerID ?? UUID()) }
        
        return completedHabitRecords.count
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            StatisticTableViewCell.self,
            forCellReuseIdentifier: Constants.statisticViewCell
        )
    }
    
    private func updatePlaceholderVisibility() {
        let hasData = statistics.contains { $0.value > 0 }
        
        if hasData {
            placeholderPresenter?.hidePlaceholder()
        } else {
            tableView.isHidden = true
            placeholderPresenter?.showPlaceholder(
                image: Asset.statisticPlaceholder.image,
                text: Constants.statisticVCPlaceholderText
            )
        }
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
    
    @objc private func handleCompletedTrackersDidUpdate() {
        calculateStatistics()
    }
}

extension StatisticViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return statistics.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        1
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
        
        let statistic = statistics[indexPath.section]
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
    
    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        12
    }
}
