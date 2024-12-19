//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.trackersVcTitleLabel
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton.systemButton(
            with: Asset.plusButton.image,
            target: nil,
            action: nil
        )
        button.frame.size = CGSize(width: 19, height: 18)
        button.tintColor = Asset.ypBlack.color
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.frame.size = CGSize(width: 100, height: 34)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.trackersVcSearchPlaceholder
        searchBar.layer.cornerRadius = 8
        searchBar.layer.masksToBounds = true
        searchBar.backgroundImage = UIImage()
        
        let textField = searchBar.searchTextField
        textField.enablesReturnKeyAutomatically = false
        textField.returnKeyType = .go
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
        let imageView = UIImageView(image: Asset.starPlaceholder.image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Asset.ypLightGray.color
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.trackersVcPlaceholderLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var contextMenuManager: ContextMenuManager?
    private var longTappedCell: TrackerCell?
    private var pinnedTrackers: Set<UUID> = []
    private var currentDate: Date = Date() {
        didSet {
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    private var currentWeekday: Weekday {
        let weekdayIndex = Calendar.current.component(.weekday, from: currentDate)
        let correctedIndex = (weekdayIndex + 5) % 7 + 1
        return Weekday(rawValue: correctedIndex) ?? .sunday
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadTrackersFromCoreData()
        trackerStore.setupFetchedResultsController()
        
        trackerStore.onDataChange = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        trackerStore.fetchTrackers { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        contextMenuManager = ContextMenuManager(
            options: ["Закрепить", "Редактировать", "Удалить"]
        )
        setupLongPressGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .createdTracker, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updatedTracker, object: nil)
    }
    
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    private func setupView() {
        searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
        setupNotificationObserver()
        updatePlaceholderVisibility()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTracker(_:)),
            name: .updatedTracker,
            object: nil
        )
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseID)
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        view.addSubview(collectionView)
    }
    
    private func updatePlaceholderVisibility() {
        let hasTrackersForCurrentDate = !categories.flatMap { $0.trackers }.isEmpty
        placeholderImageView.isHidden = hasTrackersForCurrentDate
        placeholderLabel.isHidden = hasTrackersForCurrentDate
        collectionView.isHidden = !hasTrackersForCurrentDate
    }
    
    private func filteredCategories() -> [TrackerCategory] {
        return categories.compactMap { category in
            let trackers = category.trackers.filter {
                $0.schedule.isEmpty
                ? Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                : $0.schedule.contains(currentWeekday)
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }.sorted { $0.title < $1.title }
    }
    
    private func presentEventViewController(
        for trackerType: TrackerType,
        in navigationController: UINavigationController
    ) {
        let eventVC = EventViewController(trackerType: trackerType)
        eventVC.modalPresentationStyle = .pageSheet
        eventVC.onTrackerCreated = { newTracker in
            NotificationCenter.default.post(name: .createdTracker, object: newTracker)
            navigationController.dismiss(animated: true, completion: nil)
        }
        navigationController.pushViewController(eventVC, animated: true)
    }
    
    private func presentTypeSelection() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        let navigationController = UINavigationController(rootViewController: typeSelectionVC)
        navigationController.modalPresentationStyle = .pageSheet
        typeSelectionVC.onTrackerTypeSelected = { [weak self] trackerType in
            self?.presentEventViewController(for: trackerType, in: navigationController)
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    private func sortCategories(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        categories.sorted { $0.title < $1.title }
    }
    
    private func findIndexPath(for trackerID: UUID) -> IndexPath? {
        for (sectionIndex, category) in filteredCategories().enumerated() {
            if let itemIndex = category.trackers.firstIndex(where: { $0.id == trackerID }) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    private func showDeleteConfirmation(for trackerID: UUID) {
        AlertService.showDeleteConfirmationAlert(
            title: Constants.trackersVcDeleteConfirmationAlertTitle,
            onDelete: { [weak self] in
                guard let self = self else { return }
                self.trackerStore.deleteTracker(by: trackerID)
                self.reloadTrackers()
            },
            presenter: self
        )
    }
    
    func loadTrackersFromCoreData() {
        let categoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)
        let coreDataCategories = categoryStore.fetchCategories()
        
        categories = coreDataCategories.compactMap { coreDataCategory in
            let coreDataTrackers = coreDataCategory.trackers as? Set<TrackerCoreData> ?? []
            let trackers = coreDataTrackers.map { Tracker(coreDataTracker: $0) }
            
            guard !trackers.isEmpty else { return nil } // Исключаем пустые категории
            return TrackerCategory(
                title: coreDataCategory.title ?? "",
                trackers: trackers
            )
        }
        
        let recordStore = TrackerRecordStore(context: CoreDataStack.shared.mainContext)
        completedTrackers = Set(recordStore.fetchAllRecords().map { TrackerRecord(coreDataRecord: $0) })
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    
    @objc private func addTracker(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        
        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == tracker.category }) {
            var updatedTrackers = categories[existingCategoryIndex].trackers
            updatedTrackers.append(tracker)
            
            categories[existingCategoryIndex] = TrackerCategory(
                title: categories[existingCategoryIndex].title,
                trackers: updatedTrackers
            )
        } else {
            let newCategory = TrackerCategory(
                title: tracker.category,
                trackers: [tracker]
            )
            categories.append(newCategory)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc private func updateTracker(_ notification: Notification) {
        guard let updatedTracker = notification.object as? Tracker else { return }
        
        for (index, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == updatedTracker.id }) {
                var updatedTrackers = category.trackers
                updatedTrackers.remove(at: trackerIndex)
                categories[index] = TrackerCategory(title: category.title, trackers: updatedTrackers)
                break
            }
        }
        
        categories.removeAll(where: { $0.trackers.isEmpty })
        
        let trackerStore = TrackerStore(context: CoreDataStack.shared.mainContext)
        trackerStore.updateTracker(
            updatedTracker,
            name: updatedTracker.name,
            color: updatedTracker.color,
            emoji: updatedTracker.emoji,
            schedule: updatedTracker.schedule,
            category: updatedTracker.category
        )
        
        loadTrackersFromCoreData()
    }
    
    @objc private func addButtonTapped() {
        presentTypeSelection()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupLayout() {
        view.backgroundColor = Asset.ypWhite.color
        
        [titleLabel, searchBar, placeholderImageView,
         collectionView, placeholderLabel].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func reloadTrackers() {
        loadTrackersFromCoreData()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func presentEditEventViewController(for editableTracker: EditableTracker, cell: TrackerCell) {
        let tracker = editableTracker.tracker
        let counterLabelText = cell.counterLabelText ?? "0 дней"
        
        let eventVC = EventViewController(
            trackerType: tracker.schedule.isEmpty ? .irregularEvent : .habit,
            isEditable: true
        )
        
        eventVC.configure(with: tracker, daysText: counterLabelText)
        
        let navigationController = UINavigationController(rootViewController: eventVC)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func togglePin(for trackerID: UUID) {
        guard let indexPath = findIndexPath(for: trackerID) else { return }
        
        if pinnedTrackers.contains(trackerID) {
            pinnedTrackers.remove(trackerID)
        } else {
            pinnedTrackers.insert(trackerID)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
              let trackerID = cell.trackerID,
              let tracker = findTracker(by: trackerID) else { return }
        
        let editableTracker = EditableTracker(tracker: tracker, isEditable: true)
        let backViewFrame = cell.convert(cell.backViewFrame, to: view.window)
        
        contextMenuManager?.showContextMenu(
            under: backViewFrame,
            options: ["Закрепить", "Редактировать", "Удалить"],
            data: editableTracker
        ) { [weak self] selectedIndex, editableTracker in
            guard let self = self else { return }
            
            switch selectedIndex {
            case 0:
                self.togglePin(for: editableTracker.tracker.id)
                print("Закрепить")
            case 1:
                self.presentEditEventViewController(for: editableTracker, cell: cell)
                print("Редактировать")
            case 2:
                self.showDeleteConfirmation(for: editableTracker.tracker.id)
                print("Удалить")
            default:
                break
            }
        }
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func toggleCompletion(for trackerID: UUID) {
        guard findTracker(by: trackerID) != nil else { return }
        
        if isFutureDate(currentDate) { return }
        
        let recordStore = TrackerRecordStore(context: CoreDataStack.shared.mainContext)
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        
        if isTrackerCompleted(trackerID: trackerID, on: currentDateOnly, using: recordStore) {
            removeCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        } else {
            addCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        }
        
        updateCompletedTrackers(using: recordStore)
        reloadTrackerCell(for: trackerID)
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: date)
        return selectedDate > today
    }
    
    private func isTrackerCompleted(
        trackerID: UUID,
        on date: Date,
        using store: TrackerRecordStore
    ) -> Bool {
        store.fetchRecords(for: trackerID).contains(date)
    }
    
    private func addCompletion(
        for trackerID: UUID,
        on date: Date,
        using store: TrackerRecordStore
    ) {
        store.addRecord(for: trackerID, on: date)
    }
    
    private func removeCompletion(
        for trackerID: UUID,
        on date: Date,
        using store: TrackerRecordStore
    ) {
        store.deleteRecord(for: trackerID, on: date)
    }
    
    private func updateCompletedTrackers(using store: TrackerRecordStore) {
        completedTrackers = Set(store.fetchAllRecords().map { TrackerRecord(coreDataRecord: $0) })
    }
    
    private func reloadTrackerCell(for trackerID: UUID) {
        if let indexPath = findIndexPath(for: trackerID) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func findTracker(by id: UUID) -> Tracker? {
        return categories
            .flatMap { $0.trackers }
            .first(where: { $0.id == id })
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories().count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let filteredTrackers = filteredCategories()
        guard section < filteredCategories().count else { return 0 }
        return filteredTrackers[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let filteredCategories = filteredCategories()
        
        guard indexPath.section < filteredCategories.count,
              indexPath.item < filteredCategories[indexPath.section].trackers.count else {
            fatalError("Invalid indexPath: \(indexPath)")
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let completionCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        let isCompletedToday = completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: currentDateOnly))
        let isPinned = pinnedTrackers.contains(tracker.id)
        
        cell.configure(
            with: tracker,
            completed: isCompletedToday,
            completionCount: completionCount,
            isPinned: isPinned
        )
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
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
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}
