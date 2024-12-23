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
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var contextMenuManager: ContextMenuManager?
    private var longTappedCell: TrackerCell?
    private var pinnedTrackers: Set<UUID> = []
    private var selectedFilter: TrackerFilter = .allTrackers
    private var filteredTrackers: [Tracker] = []
    private var allTrackers: [Tracker] = []
    private var searchResults: [Tracker] = []
    
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
        setupFilterButton()
        applyCurrentFilter()
        loadTrackersFromCoreData()
        trackerStore.setupFetchedResultsController()
        
        trackerStore.onDataChange = { [weak self] in
            self?.collectionView.reloadData()
            self?.loadTrackersFromCoreData()
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
        let hasTrackersForCurrentDate = !categories.flatMap { $0.trackers }.isEmpty
        let hasSearchResults = !searchResults.isEmpty
        let hasFilteredTrackersForCurrentDate = !filteredTrackers.isEmpty
        let isTodayFilterWithDifferentDate = (selectedFilter == .today &&
            !Calendar.current.isDate(currentDate, inSameDayAs: Date()))
        
        print("""
            Обновление видимости плейсхолдера:
            Поиск активен: \(isSearchActive),
            Трекеры для текущей даты: \(hasTrackersForCurrentDate),
            Фильтрованные трекеры: \(hasFilteredTrackersForCurrentDate),
            Результаты поиска: \(hasSearchResults),
            Фильтр "Трекеры на сегодня" для другой даты: \(isTodayFilterWithDifferentDate)
            """)
        
        if isSearchActive {
            placeholderImageView.image = Asset.emptySearchPlaceholder.image
            placeholderImageView.isHidden = hasSearchResults
            placeholderLabel.text = "Ничего не найдено"
            placeholderLabel.isHidden = hasSearchResults
            collectionView.isHidden = !hasSearchResults
            filterButton.isHidden = true
            return
        }
        
        if isTodayFilterWithDifferentDate {
            placeholderImageView.image = Asset.emptySearchPlaceholder.image
            placeholderImageView.isHidden = hasFilteredTrackersForCurrentDate
            placeholderLabel.text = "Ничего не найдено"
            placeholderLabel.isHidden = hasFilteredTrackersForCurrentDate
            collectionView.isHidden = !hasFilteredTrackersForCurrentDate
            filterButton.isHidden = false
            return
        }
        
//        if !hasTrackersForCurrentDate {
//            placeholderImageView.image = Asset.starPlaceholder.image
//            placeholderImageView.isHidden = false
//            placeholderLabel.text = Constants.trackersVcPlaceholderLabel
//            placeholderLabel.isHidden = false
//            collectionView.isHidden = true
//            filterButton.isHidden = true
//            return
//        }
        
        collectionView.isHidden = false
        filterButton.isHidden = false
    }
    
    private func filteredCategories() -> [TrackerCategory] {
        let pinnedTrackers = categories
            .flatMap { $0.trackers }
            .filter { $0.isPinned && isTrackerVisibleOnCurrentDate($0) }
        
        print("Закреплённые трекеры: \(pinnedTrackers.map { $0.name })")
        
        let nonPinnedCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter {
                !$0.isPinned && isTrackerVisibleOnCurrentDate($0)
            }
            print("Категория: \(category.title), Фильтрованные трекеры: \(filteredTrackers.map { $0.name })")
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "Закреплённые", trackers: pinnedTrackers)
            print("Формируем категорию Закреплённые: \(pinnedTrackers.map { $0.name })")
            return [pinnedCategory] + nonPinnedCategories
        }
        print("Финальные категории: \(nonPinnedCategories.map { $0.title })")
        return nonPinnedCategories
    }
    
    private func isTrackerVisibleOnCurrentDate(_ tracker: Tracker) -> Bool {
        let isVisible: Bool
            if tracker.schedule.isEmpty {
                isVisible = Calendar.current.isDate(tracker.date, inSameDayAs: currentDate)
            } else {
                isVisible = tracker.schedule.contains(currentWeekday)
            }
            
            print("Трекер: \(tracker.name), Расписание: \(tracker.schedule), Сегодня: \(currentWeekday), Видим: \(isVisible)")
            return isVisible
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
    
    private func filterTrackers(by query: String) {
        print("Фильтрация по запросу: \(query)")
        searchResults = categories
            .flatMap { $0.trackers }
            .filter { $0.name.lowercased().contains(query.lowercased()) }
        print("Фильтрация завершена. Найдено: \(searchResults.count) трекеров")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Поиск. Введённый текст: \(searchText)")
        if searchText.isEmpty {
            searchResults = []
            print("Поиск очищен. Всего трекеров: \(categories.flatMap { $0.trackers }.count)")
        } else {
            filterTrackers(by: searchText)
            print("Поиск активен. Найдено трекеров: \(searchResults.count)")
        }
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults = []
        searchBar.resignFirstResponder()
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func loadTrackersFromCoreData() {
        let coreDataCategories = categoryStore.fetchCategories()
        
        print("Загружаем категории из Core Data. Найдено: \(coreDataCategories.count)")
        categories = coreDataCategories.compactMap { coreDataCategory -> TrackerCategory? in
            let coreDataTrackers = coreDataCategory.trackers as? Set<TrackerCoreData> ?? []
            let trackers = coreDataTrackers.map { Tracker(coreDataTracker: $0) }
            
            print("Категория: \(coreDataCategory.title ?? "Без названия"), Трекеры: \(trackers.map { $0.name })")
            
            guard !trackers.isEmpty else { 
                print("Категория \(coreDataCategory.title ?? "Без названия") пуста, пропускаем")
                return nil }
            return TrackerCategory(
                title: coreDataCategory.title ?? "",
                trackers: trackers
            )
        }
        
        completedTrackers = Set(
                TrackerRecordStore(context: CoreDataStack.shared.mainContext)
                    .fetchAllRecords()
                    .map { TrackerRecord(coreDataRecord: $0) }
            )
        
        allTrackers = categories.flatMap { $0.trackers }
        print("Загруженные категории: \(categories.map { $0.title })")
        applyCurrentFilter()
        
        print("Выполненные трекеры: \(completedTrackers.count)")
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func applyCurrentFilter() {
        print("Применяем фильтр: \(selectedFilter)")
        
        switch selectedFilter {
        case .allTrackers:
            filteredTrackers = categories
                .flatMap { $0.trackers }
                .filter { isTrackerVisibleOnCurrentDate($0) }
            print("Фильтр: Все трекеры. Количество трекеров: \(filteredTrackers.count)")
            print("Трекеры до фильтрации (allTrackers): \(allTrackers)")
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            let selectedDay = Calendar.current.startOfDay(for: currentDate)
            if today != selectedDay {
                filteredTrackers = []
            } else {
                filteredTrackers = categories
                    .flatMap { $0.trackers }
                    .filter {
                    Calendar.current.isDate(
                        $0.date, inSameDayAs: today)
                        && isTrackerVisibleOnCurrentDate($0
                        )
                }
            }
            print("Фильтр: Сегодня. Количество трекеров: \(filteredTrackers.count)")
        case .completed:
            let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
            filteredTrackers = categories
                .flatMap { $0.trackers }
                .filter {
                    completedTrackers.contains(TrackerRecord(trackerId: $0.id, date: currentDateOnly))
            }
            print("Фильтр: Завершённые. Количество трекеров: \(filteredTrackers.count)")
        case .incomplete:
            let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
            filteredTrackers = categories
                .flatMap { $0.trackers }
                .filter {
                !completedTrackers.contains(TrackerRecord(trackerId: $0.id, date: currentDateOnly))
            }
            print("Фильтр: Незавершённые. Количество трекеров: \(filteredTrackers.count)")
        }
        
        print("Результат фильтрации (filteredTrackers): \(filteredTrackers)")
        categories = filteredCategories()
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController(selectedFilter: selectedFilter)
        filterVC.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.selectedFilter = filter
            
                    if filter == .today {
                        self.currentDate = Date() // Устанавливаем текущую дату
                        self.datePicker.setDate(self.currentDate, animated: true) // Обновляем UIDatePicker
                    }
            
            self.applyCurrentFilter()
            self.dismiss(animated: true)
        }
        present(filterVC, animated: true)
    }
    
    @objc private func addTracker(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { 
            print("Ошибка: Получен объект не типа Tracker")
            return }
        
        print("Добавляем трекер: \(tracker.name), ID: \(tracker.id), Категория: \(tracker.category)")
        
        if let existingCategoryIndex = categories.firstIndex(where: { $0.title == tracker.category }) {
            print("Категория найдена: \(tracker.category)")
            
            var updatedTrackers = categories[existingCategoryIndex].trackers
            updatedTrackers.append(tracker)
            
            categories[existingCategoryIndex] = TrackerCategory(
                title: categories[existingCategoryIndex].title,
                trackers: updatedTrackers
            )
        } else {
            print("Категория не найдена, создаём новую: \(tracker.category)")
            let newCategory = TrackerCategory(
                title: tracker.category,
                trackers: [tracker]
            )
            categories.append(newCategory)
        }
        
        print("Текущие категории после добавления: \(categories.map { $0.title })")
        
        allTrackers = categories.flatMap { $0.trackers }
        applyCurrentFilter()
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
        let sortedSchedule = updatedTracker.schedule.sorted { $0.rawValue < $1.rawValue }
        
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
        applyCurrentFilter()
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
        
        print("Конфигурация EventViewController для трекера: \(tracker.name), Тип: \(tracker.schedule.isEmpty ? ".irregularEvent" : ".habit")")
        eventVC.configure(with: tracker, daysText: counterLabelText)
        
        let navigationController = UINavigationController(rootViewController: eventVC)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func togglePin(for trackerID: UUID) {
        guard let tracker = findTracker(by: trackerID) else { return }
        
        trackerStore.updatePinStatus(
            for: trackerID,
            isPinned: !tracker.isPinned
        )
        
        loadTrackersFromCoreData()
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
        guard let tracker = findTracker(by: trackerID) else { return }

        if isFutureDate(currentDate) { return }

        let recordStore = TrackerRecordStore(context: CoreDataStack.shared.mainContext)
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)

        if isTrackerCompleted(trackerID: trackerID, on: currentDateOnly, using: recordStore) {
            removeCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        } else {
            addCompletion(for: trackerID, on: currentDateOnly, using: recordStore)
        }

        // Обновляем список завершённых трекеров
        updateCompletedTrackers(using: recordStore)
        applyCurrentFilter() // Обновляем отображение после изменения
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
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        
        if isSearchActive {
            filterTrackers(by: searchBar.text ?? "")
            collectionView.reloadData()
        } else {
            if let indexPath = findIndexPath(for: trackerID) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func findTracker(by id: UUID) -> Tracker? {
        return allTrackers.first(where: { $0.id == id })
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        if isSearchActive {
            let groupedResults = Dictionary(grouping: searchResults, by: { $0.category })
            return groupedResults.keys.count
        } else {
            return filteredTrackers.isEmpty ? 0 : categories.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        
        if isSearchActive {
            let groupedResults = Dictionary(grouping: searchResults, by: { $0.category })
            let sortedKeys = groupedResults.keys.sorted()
            
            print("Отображение секции \(section) в поиске. Категория: \(sortedKeys[section])")
            
            guard section < sortedKeys.count else { return 0 }
            
            let categoryKey = sortedKeys[section]
            print("Отображение секции \(section). Категория: \(categories[section].title), Трекеры: \(categories[section].trackers.count)")
            return groupedResults[categoryKey]?.count ?? 0
        } else {
            return filteredCategories()[section].trackers.count
        }
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
        
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        if isSearchActive {
            let groupedResults = Dictionary(grouping: searchResults, by: { $0.category })
            let sortedKeys = groupedResults.keys.sorted()
            let categoryKey = sortedKeys[indexPath.section]
            header.configure(with: categoryKey)
        } else {
            let categories = filteredCategories()
            header.configure(with: categories[indexPath.section].title)
        }
        
        return header
    }
    
    private func getTracker(for indexPath: IndexPath) -> Tracker? {
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        
        if isSearchActive {
            let groupedResults = Dictionary(grouping: searchResults, by: { $0.category })
            let sortedKeys = groupedResults.keys.sorted()
            
            guard indexPath.section < sortedKeys.count else { return nil }
            let categoryKey = sortedKeys[indexPath.section]
            
            guard let trackersInCategory = groupedResults[categoryKey],
                  indexPath.item < trackersInCategory.count else { return nil }
            
            return trackersInCategory[indexPath.item]
        } else {
            let categories = filteredCategories()
            
            guard indexPath.section < categories.count else { return nil }
            let trackers = categories[indexPath.section].trackers
            
            guard indexPath.item < trackers.count else { return nil }
        
            return trackers[indexPath.item]
        }
    }
    
    private func configureCell(_ cell: TrackerCell, with tracker: Tracker) {
        let completionCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let currentDateOnly = Calendar.current.startOfDay(for: currentDate)
        let isCompletedToday = completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: currentDateOnly))
        
        cell.configure(
            with: tracker,
            completed: isCompletedToday,
            completionCount: completionCount,
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
