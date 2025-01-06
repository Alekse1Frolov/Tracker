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
        collectionView.backgroundColor = Asset.ypWhite.color
        return collectionView
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)
    private var placeholderPresenter: PlaceholderPresenter?
    private var contextMenuManager: ContextMenuManager?
    private var longTappedCell: TrackerCell?
    private var selectedFilter: TrackerFilter = .allTrackers
    private var currentDate: Date = Date() {
        didSet {
            collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }
    
    private var isFirstLaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isFirstLaunch") == false
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "isFirstLaunch")
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
        setupFilterButton()
        trackerStore.setupFetchedResultsController()
        trackerStore.fetchTrackersIfNeeded()
        selectedFilter = loadSelectedFilter()
        applyCurrentFilter()
        
        placeholderPresenter = PlaceholderPresenter(
            imageView: placeholderImageView,
            label: placeholderLabel
            
        )
        handleFirstLaunch()
        
        contextMenuManager = ContextMenuManager(
            options: ["Закрепить", "Редактировать", "Удалить"]
        )
        setupLongPressGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .createdTracker, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updatedTracker, object: nil)
    }
    
    private func setupView() {
        searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupLayout()
        setupNavigationBar()
        setupCollectionView()
        setupNotificationObserver()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        view.addSubview(filterButton)
        setupFilterButtonConstraints()
        view.bringSubviewToFront(filterButton)
    }
    
    private func setupFilterButtonConstraints() {
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
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
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        let hasTrackersForDate = !(trackerStore.fetchedResultsController?.fetchedObjects?.isEmpty ?? true)
        let searchResultsEmpty = isSearchActive && !hasTrackersForDate
        let noFilteredResults = !hasTrackersForDate && !isSearchActive
        
        print("isSearchActive: \(isSearchActive), searchResultsEmpty: \(searchResultsEmpty), hasTrackersForDate: \(hasTrackersForDate)")
        print("Трекеры для текущей даты: \(trackerStore.fetchTrackersForCurrentDate(currentDate))")
        print("Содержимое поискового запроса: \(searchBar.text ?? "nil")")
        
        if searchResultsEmpty {
            placeholderPresenter?.showPlaceholder(
                image: Asset.emptySearchPlaceholder.image,
                text: Constants.trackersVcEmptySearchPlaceholderText
            )
            collectionView.isHidden = true
        } else if noFilteredResults {
            placeholderPresenter?.showPlaceholder(
                image: Asset.emptySearchPlaceholder.image,
                text: Constants.trackersVcEmptySearchPlaceholderText
            )
            collectionView.isHidden = true
        } else {
            placeholderPresenter?.hidePlaceholder()
            collectionView.isHidden = false
        }
        filterButton.isHidden = !hasTrackersForDate || isSearchActive
    }
    
    private func handleFirstLaunch() {
        if isFirstLaunch {
            print("Первый запуск приложения. Показываем стартовый плейсхолдер.")
            placeholderPresenter?.showPlaceholder(
                image: Asset.starPlaceholder.image,
                text: Constants.trackersVcPlaceholderLabel
            )
            collectionView.isHidden = true
            filterButton.isHidden = true
            isFirstLaunch = false
        }
    }
    
    private func applyCurrentFilter() {
        switch selectedFilter {
        case .allTrackers:
            let categories = trackerStore.fetchTrackersForCurrentDate(currentDate)
            print("Все трекеры на дату \(currentDate): \(categories.flatMap { $0.trackers.map { $0.name } })")
        case .today:
            let categories = trackerStore.fetchTrackersForCurrentDate(currentDate)
            print("Трекеры на сегодня: \(categories.flatMap { $0.trackers.map { $0.name } })")
        case .completed:
            let categories = trackerStore.fetchCompletedTrackers(for: currentDate)
            print("Завершённые трекеры: \(categories.flatMap { $0.trackers.map { $0.name } })")
        case .incomplete:
            let categories = trackerStore.fetchIncompleteTrackers(for: currentDate)
            print("Незавершённые трекеры: \(categories.flatMap { $0.trackers.map { $0.name } })")
        }
        
        let predicate: NSPredicate
        switch selectedFilter {
        case .allTrackers, .today:
            predicate = trackerStore.currentPredicate(for: currentDate)
        case .completed:
            predicate = trackerStore.completedTrackersPredicate(for: currentDate)
        case .incomplete:
            predicate = trackerStore.incompleteTrackersPredicate(for: currentDate)
        }
        trackerStore.setupFetchedResultsController(predicate: predicate)
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
        
        if let trackers = trackerStore.fetchedResultsController?.fetchedObjects {
            print("Фильтр: \(selectedFilter), Найдено трекеров: \(trackers.count)")
        } else {
            print("Фильтр: \(selectedFilter), Найдено трекеров: 0")
        }
        
        if let sections = trackerStore.fetchedResultsController?.sections {
            print("Применён фильтр: \(selectedFilter)")
            for section in sections {
                print("Категория: \(section.name), Количество трекеров: \(section.numberOfObjects)")
            }
        } else {
            print("Применён фильтр: \(selectedFilter), Секций нет")
        }
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
    
    private func filteredCategories() -> [TrackerCategory] {
        guard let sections = trackerStore.fetchedResultsController?.sections else {
            print("Нет секций для фильтрации.")
            return []
        }
        
        var pinnedTrackers: [Tracker] = []
        var categorizedTrackers: [TrackerCategory] = []
        
        for section in sections {
            guard let objects = section.objects as? [TrackerCoreData] else { continue }
            let trackers = objects.compactMap { Tracker(coreDataTracker: $0) }
            
            print("Секция: \(section.name), Все трекеры:")
            trackers.forEach { tracker in
                print("- \(tracker.name), Тип: \(tracker.type), Дата: \(String(describing: tracker.date)), Расписание: \(tracker.schedule)")
            }
            
            let filteredTrackers: [Tracker]
            switch selectedFilter {
            case .allTrackers, .today:
                filteredTrackers = trackers
            case .completed:
                let completedTrackerIDs = trackerStore.fetchCompletedTrackersSet(for: currentDate)
                filteredTrackers = trackers.filter { completedTrackerIDs.contains($0.id) }
            case .incomplete:
                let completedTrackerIDs = trackerStore.fetchCompletedTrackersSet(for: currentDate)
                filteredTrackers = trackers.filter { !completedTrackerIDs.contains($0.id) }
            }
            
            let (pinned, regular) = filteredTrackers.partitioned(by: { $0.isPinned })
            pinnedTrackers.append(contentsOf: pinned)
            
            if !regular.isEmpty {
                categorizedTrackers.append(TrackerCategory(title: section.name, trackers: regular))
            }
        }
        
        if !pinnedTrackers.isEmpty {
            categorizedTrackers.insert(TrackerCategory(title: "Закреплённые", trackers: pinnedTrackers), at: 0)
        }
        
        print("Категории после фильтрации:")
        categorizedTrackers.forEach { category in
            print("- \(category.title): \(category.trackers.map { $0.name })")
        }
        
        return categorizedTrackers
    }
    
    private func showDeleteConfirmation(for trackerID: UUID) {
        AlertService.showDeleteConfirmationAlert(
            title: Constants.trackersVcDeleteConfirmationAlertTitle,
            onDelete: { [weak self] in
                guard let self = self else { return }
                self.trackerStore.deleteTracker(by: trackerID)
                self.applyCurrentFilter()
            },
            presenter: self
        )
    }
    
    private func saveSelectedFilter() {
        UserDefaults.standard.set(selectedFilter.rawValue, forKey: "SelectedFilter")
    }
    
    private func loadSelectedFilter() -> TrackerFilter {
        if let rawValue = UserDefaults.standard.string(forKey: "SelectedFilter"),
           let filter = TrackerFilter(rawValue: rawValue) {
            return filter
        }
        return .allTrackers
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            resetToDefaultFiltering()
            return
        }
        
        let selectedDate = datePicker.date.strippedTime() ?? datePicker.date
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
        
        let habitPredicate = NSPredicate(
            format: "(type == %@ AND ANY schedule.number == %d AND name CONTAINS[cd] %@)",
            TrackerType.habit.rawValue, currentWeekday.rawValue, searchText
        )
        let irregularEventPredicate = NSPredicate(
            format: "(type == %@ AND date >= %@ AND date < %@ AND name CONTAINS[cd] %@)",
            TrackerType.irregularEvent.rawValue,
            selectedDate as NSDate,
            nextDay as NSDate,
            searchText
        )
        
        let compoundPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [habitPredicate, irregularEventPredicate]
        )
        
        trackerStore.setupFetchedResultsController(predicate: compoundPredicate)
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        resetToDefaultFiltering()
    }
    
    private func resetToDefaultFiltering() {
        let defaultPredicate = trackerStore.currentPredicate(for: datePicker.date)
        trackerStore.setupFetchedResultsController(predicate: defaultPredicate)
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController(selectedFilter: selectedFilter)
        filterVC.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.selectedFilter = filter
            
            if filter == .today {
                self.currentDate = Date()
                self.datePicker.setDate(self.currentDate, animated: true)
            }
            self.saveSelectedFilter()
            self.applyCurrentFilter()
            self.dismiss(animated: true)
        }
        present(filterVC, animated: true)
    }
    
    @objc private func addButtonTapped() {
        presentTypeSelection()
    }
    
    @objc private func addTracker(_ notification: Notification) {
        applyCurrentFilter()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc private func updateTracker(_ notification: Notification) {
        applyCurrentFilter()
        collectionView.reloadData()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.strippedTime() ?? sender.date
        
        let currentWeekday = Calendar.current.component(.weekday, from: currentDate)
        print("Дата изменена на: \(currentDate), День недели: \(currentWeekday)")
        
        applyCurrentFilter()
        collectionView.reloadData()
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
    
    private func presentEditEventViewController(for editableTracker: EditableTracker, cell: TrackerCell) {
        let tracker = editableTracker.tracker
        let counterLabelText = cell.counterLabelText ?? "0 дней"
        
        let eventVC = EventViewController(
            trackerType: tracker.schedule.isEmpty ? .irregularEvent : .habit,
            isEditable: true
        )
        
        print("Конфигурация EventViewController для трекера: \(tracker.name), Тип: \(tracker.schedule.isEmpty ? ".irregularEvent" : ".habit")")
        eventVC.configure(with: tracker, daysText: counterLabelText)
        
        let navigationController = UINavigationController(rootViewController: eventVC)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func togglePin(for trackerID: UUID) {
        if let tracker = trackerStore.fetchTracker(byID: trackerID) {
            if tracker.isPinned {
                trackerStore.unpinTracker(by: trackerID)
            } else {
                trackerStore.pinTracker(by: trackerID)
            }
            applyCurrentFilter()
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
              let trackerID = cell.trackerID,
              let tracker = findTracker(by: trackerID) else { return }
        
        let isPinned = trackerStore.fetchTracker(byID: tracker.id)?.isPinned ?? false
        let editableTracker = EditableTracker(
            tracker: tracker,
            isEditable: true,
            currentCategory: tracker.category
        )
        let backViewFrame = cell.convert(cell.backViewFrame, to: view.window)
        
        let options = isPinned
        ? ["Открепить", "Редактировать", "Удалить"]
        : ["Закрепить", "Редактировать", "Удалить"]
        
        contextMenuManager?.showContextMenu(
            under: backViewFrame,
            options: options,
            data: editableTracker
        ) { [weak self] selectedIndex, editableTracker in
            guard let self = self else { return }
            
            switch selectedIndex {
            case 0:
                self.togglePin(for: editableTracker.tracker.id)
            case 1:
                self.presentEditEventViewController(for: editableTracker, cell: cell)
            case 2:
                self.showDeleteConfirmation(for: editableTracker.tracker.id)
            default:
                break
            }
        }
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func toggleCompletion(for trackerID: UUID) {
        guard findTracker(by: trackerID) != nil else {
            print("Трекер с ID \(trackerID) не найден.")
            return
        }
        
        if isFutureDate(currentDate) {
            print("Невозможно завершить трекер на будущую дату: \(currentDate)")
            return
        }
        
        let recordStore = TrackerRecordStore(context: CoreDataStack.shared.mainContext)
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        let isAlreadyCompleted = isTrackerCompleted(trackerID: trackerID, on: currentDateOnly, using: recordStore)
        
        if isAlreadyCompleted {
            print("Отменяем завершение трекера с ID \(trackerID) на дату \(currentDateOnly)")
            removeCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        } else {
            print("Отмечаем трекер с ID \(trackerID) как завершённый на дату \(currentDateOnly)")
            addCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        }
        
        applyCurrentFilter()
        
        if let indexPath = findIndexPath(for: trackerID) {
            print("Обновление ячейки в секции \(indexPath.section), строка \(indexPath.item)")
            collectionView.reloadItems(at: [indexPath])
        } else {
            print("Не удалось найти IndexPath для трекера \(trackerID)")
        }
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
    
    private func findTracker(by id: UUID) -> Tracker? {
        return filteredCategories().flatMap { $0.trackers }.first(where: { $0.id == id })
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let categories = filteredCategories()
        print("Количество секций: \(categories.count)")
        return categories.isEmpty ? 0 : categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let categories = filteredCategories()
        guard section < categories.count else {
            print("Секция \(section) пуста или выходит за пределы массива")
            return 0
        }
        let trackersCount = categories[section].trackers.count
        print("Секция: \(categories[section].title), Количество трекеров: \(trackersCount)")
        return trackersCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let tracker = getTracker(for: indexPath) else {
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        configureCell(cell, with: tracker)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseID,
            for: indexPath
        ) as? TrackerCategoryHeader else {
            return UICollectionReusableView()
        }
        
        let categories = filteredCategories()
        header.configure(with: categories[indexPath.section].title)
        return header
    }
    
    private func getTracker(for indexPath: IndexPath) -> Tracker? {
        let categories = filteredCategories()
        guard indexPath.section < categories.count else { return nil }
        let trackers = categories[indexPath.section].trackers
        guard indexPath.item < trackers.count else { return nil }
        return trackers[indexPath.item]
    }
    
    private func configureCell(_ cell: TrackerCell, with tracker: Tracker) {
        let completedTrackers = trackerStore.fetchCompletedTrackersSet(for: currentDate)
        print("Конфигурация ячейки для трекера: \(tracker.name), Тип: \(tracker.type), Расписание: \(tracker.schedule), Дата: \(String(describing: tracker.date))")
        print("Завершённые трекеры на \(currentDate): \(completedTrackers)")
        let isCompleted: Bool
        
        if tracker.type == .habit {
            isCompleted = tracker.schedule.contains(currentWeekday) && completedTrackers.contains(tracker.id)
        } else if tracker.type == .irregularEvent {
            isCompleted = Calendar.current.isDate(tracker.date, inSameDayAs: currentDate) && completedTrackers.contains(tracker.id)
        } else {
            isCompleted = false
        }
        
        print("Трекер: \(tracker.name), isCompleted: \(isCompleted)")
        
        cell.configure(
            with: tracker,
            completed: isCompleted,
            completionCount: trackerStore.fetchCompletionCount(for: tracker.id),
            isPinned: tracker.isPinned
        )
        cell.delegate = self
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
