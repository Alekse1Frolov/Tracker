//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.08.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(named: "PlusButton") ?? UIImage(), target: nil, action: nil)
        button.tintColor = ProjectColors.black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.layer.cornerRadius = 8
        searchBar.layer.masksToBounds = true
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = searchBar.searchTextField
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            textField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            textField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)
        ])
        
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        
        return searchBar
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "StarPlaceholder"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ProjectColors.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ProjectColors.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date() {
        didSet {
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Изначальный массив категорий:", categories)
        view.backgroundColor = ProjectColors.white
        
        setupNavigationBar()
        setupCollectionView()
        setupLayout()
        setupNotificationObserver()
        //setupDefaultCategory()
        updatePlaceholderVisibility()
    }
    
    private func setupNavigationBar() {
        
        let addButtonItem = UIBarButtonItem(customView: addButton)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = addButtonItem
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addTracker(_:)),
            name: .createdTracker,
            object: nil
        )
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseID)
        view.addSubview(collectionView)
    }
    
    private func setupDefaultCategory() {
        let defaultCategory = TrackerCategory(title: "Домашний уют", trackers: [])
        categories.append(defaultCategory)
    }
    
    private func handleCompletion(for tracker: Tracker) {
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        
        guard currentDateOnly <= Calendar.current.startOfDay(for: Date()) else {
            return
        }
        
        let record = TrackerRecord(trackerId: tracker.id, date: currentDateOnly)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        collectionView.reloadData()
    }
    
    func toggleCompletion(for tracker: Tracker) {
        handleCompletion(for: tracker)
    }
    
    @objc private func addTracker(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        
        print("Добавление трекера в категорию")
        
        var newCategories: [TrackerCategory] = []
        var trackerAdded = false
        
        for category in categories {
            if category.title == "Домашний уют" {
                var newTrackers = category.trackers
                newTrackers.append(tracker)
                
                let newCategory = TrackerCategory(title: category.title, trackers: newTrackers)
                newCategories.append(newCategory)
                trackerAdded = true
                print("Трекер добавлен в существующую категорию")
            } else {
                newCategories.append(category)
            }
        }
        
        if !trackerAdded {
            let newCategory = TrackerCategory(title: "Домашний уют", trackers: [tracker])
            newCategories.append(newCategory)
            print("Создана новая категория с трекером:", newCategory)
        }
        
        categories = newCategories
        print("Категории после добавления трекера:", categories)
        collectionView.reloadData()
        updatePlaceholderVisibility()
        print("Обновлены данные коллекции")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .createdTracker, object:  nil)
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        print("Коллекция скрыта:", isEmpty)
    }
    
    @objc private func addButtonTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        let navigationController = UINavigationController(rootViewController: typeSelectionVC)
        navigationController.modalPresentationStyle = .pageSheet
        
        typeSelectionVC.onTrackerTypeSelected = { [weak self] trackerType in
            guard let _ = self else { return }
            let habitVC = HabitViewController()
            habitVC.modalPresentationStyle = .pageSheet
            
            habitVC.onTrackerCreated = { newTracker in
                print("Созданный трекер:", newTracker)
                NotificationCenter.default.post(name: NSNotification.Name("createdTracker"), object: newTracker)
                navigationController.dismiss(animated: true,completion: nil)
            }
            typeSelectionVC.navigationController?.pushViewController(habitVC, animated: true)
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    private func setupLayout() {
        view.addSubview(addButton)
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            
            // addButton constraints
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            
            // datePicker constraints
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // searchBar constraints
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // collectionView constraints
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
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

extension TrackersViewController: TrackerCellDelegate {
    func toggleCompletion(for trackerID: UUID) {
        guard let _ = findTracker(by: trackerID) else { return }
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        
        guard currentDateOnly <= Calendar.current.startOfDay(for: Date()) else {
            print("Нельзя отметить для будущей даты")
            return
        }
        
        let record = TrackerRecord(trackerId: trackerID, date: currentDateOnly)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        
        collectionView.reloadData()
    }
    
    private func findTracker(by id: UUID) -> Tracker? {
        for category in categories {
            if let tracker = category.trackers.first(where: { $0.id == id }) {
                return tracker
            }
        }
        return nil
    }
    
    func completeTracker(id: UUID) { }
    func uncompleteTracker(id: UUID) { }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        print("Отображение трекера в ячейке:", tracker)
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        let record = TrackerRecord(trackerId: tracker.id, date: currentDateOnly)
        
        let isCompleted = completedTrackers.contains(record)
        let completionCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, completed: isCompleted, completionCount: completionCount)
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeader.reuseID,
                for: indexPath) as? TrackerCategoryHeader else { return UICollectionReusableView() }
            
            let category = categories[indexPath.section]
            header.configure(with: category.title)
            return header
        }
        return UICollectionReusableView()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 46
    }
}
