//
//  EventViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 16.11.2024.
//

import UIKit

final class EventViewController: UIViewController {
    
    // MARK: - Properties
    private let trackerType: TrackerType
    private let emojis = MockData.emojis
    private let colors = MockData.trackersColors
    private var selectedDays: [Weekday] = []
    private var selectedDaysText = ""
    private var errorLabelHeightConstraint: NSLayoutConstraint!
    private var daysContainerViewHeightConstraint: NSLayoutConstraint!
    private var nameTextFieldTopAnchorConstraint: NSLayoutConstraint!
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var isEditable: Bool
    private var currentTracker: Tracker?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let daysContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = Asset.ypBlack.color
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.eventVcTextFieldPlaceholderTitle
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
        textField.returnKeyType = .go
        textField.enablesReturnKeyAutomatically = false
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = padding
        textField.leftViewMode = .always
        return textField
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.eventVcClearButtonSystemName), for: .normal)
        button.tintColor = Asset.ypGray.color
        button.addTarget(self, action: #selector(clearNameTextField), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.eventVcMaxNameLengthErrorText
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = Asset.ypRed.color
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = Asset.ypWhite.color
        tableView.separatorColor = Asset.ypGray.color
        tableView.separatorInset = .zero
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        return tableView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.eventVcEmojiLabelTitile
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.eventVcColorLabelTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.eventVcCancelButtonTitle, for: .normal)
        button.setTitleColor(Asset.ypRed.color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = Asset.ypRed.color.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.eventVcCreateButtonTitle, for: .normal)
        button.setTitleColor(Asset.ypWhite.color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Asset.ypGray.color
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Initializer
    init(trackerType: TrackerType, isEditable: Bool = false) {
        self.trackerType = trackerType
        self.isEditable = isEditable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        nameTextField.delegate = self
        
        setupLayout()
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupScrollViewContent()
        setupClearButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if isEditable {
            if trackerType == .habit {
                titleLabel.text = "Редактирование привычки"
            } else {
                titleLabel.text = "Редактирование события"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Constants.eventVcTableViewCellId
        )
    }
    
    private func setupCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(
            EventViewControllerCell.self,
            forCellWithReuseIdentifier: Constants.eventVcEmojiCollectionCellId
        )
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(
            EventViewControllerCell.self,
            forCellWithReuseIdentifier: Constants.eventVcColorCollectionCellId)
    }
    
    private func setupLayout() {
        view.backgroundColor = Asset.ypWhite.color
        
        titleLabel.text = trackerType ==
            .habit ? Constants.eventVcNewHabitCreationTitle
        : Constants.eventVcNewIrregularEventCreationTitle
        
        [cancelButton, createButton].forEach { element in
            buttonStackView.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, scrollView, buttonStackView].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // scrollView constraints
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            // buttonStackView constraints
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // cancelButton constraints
            cancelButton.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            // createButton constraints
            createButton.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor),
            createButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor)
        ])
    }
    
    private func setupScrollViewContent() {
        if isEditable && trackerType == .habit {
            contentView.addSubview(daysContainerView)
            daysContainerView.addSubview(daysLabel)
            
            daysContainerViewHeightConstraint = daysContainerView.heightAnchor.constraint(equalToConstant: 78)
            
            NSLayoutConstraint.activate([
                // daysContainerView constraints
                daysContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                daysContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                daysContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                daysContainerViewHeightConstraint,
                
                // daysLabel constraints
                daysLabel.topAnchor.constraint(equalTo: daysContainerView.topAnchor),
                daysLabel.leadingAnchor.constraint(equalTo: daysContainerView.leadingAnchor),
                daysLabel.trailingAnchor.constraint(equalTo: daysContainerView.trailingAnchor),
                daysLabel.heightAnchor.constraint(equalToConstant: 38)
            ])
        }
        
        [nameTextField, errorLabel, tableView, emojiLabel,
         emojiCollectionView, colorLabel, colorCollectionView].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        if isEditable && trackerType == .habit {
            nameTextFieldTopAnchorConstraint = nameTextField.topAnchor.constraint(equalTo: daysContainerView.bottomAnchor)
        } else {
            nameTextFieldTopAnchorConstraint = nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        }
        
        NSLayoutConstraint.activate([
            // nameTextField constraints
            nameTextFieldTopAnchorConstraint,
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // tableView constraints
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabelHeightConstraint,
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? 150 : 75),
            
            // emojiLabel constraints
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            // emojiCollectionView constraints
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            // colorLabel constraints
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            
            // colorCollectionView constraints
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: emojiCollectionView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: emojiCollectionView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalTo: emojiCollectionView.heightAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupScrollView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // contentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    private func setupClearButton() {
        let rightViewContainer = UIView()
        [rightViewContainer, clearButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        rightViewContainer.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            rightViewContainer.widthAnchor.constraint(equalToConstant: 41),
            rightViewContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            clearButton.centerYAnchor.constraint(equalTo: rightViewContainer.centerYAnchor),
            clearButton.centerXAnchor.constraint(equalTo: rightViewContainer.centerXAnchor)
        ])
        
        nameTextField.rightView = rightViewContainer
        nameTextField.rightViewMode = .whileEditing
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        if isEditable {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text, !trackerName.isEmpty else { return }
        guard let selectedCategory = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text else { return }
        
        let trackerStore = TrackerStore(context: CoreDataStack.shared.mainContext)
        
        if isEditable, let currentTracker = currentTracker {
            trackerStore.updateTracker(
                currentTracker,
                name: trackerName,
                color: colors[selectedColorIndex?.item ?? 0]?.hexString ?? "",
                emoji: emojis[selectedEmojiIndex?.item ?? 0],
                schedule: trackerType == .habit ? selectedDays : [],
                category: selectedCategory
            )
            
            guard let updatedTracker = trackerStore.fetchTracker(byID: currentTracker.id) else { return }
            NotificationCenter.default.post(name: .updatedTracker, object: updatedTracker)
        } else {
            let newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                color: colors[selectedColorIndex?.item ?? 0]?.hexString ?? "",
                emoji: emojis[selectedEmojiIndex?.item ?? 0],
                schedule: trackerType == .habit ? selectedDays : [],
                date: Date(),
                category: selectedCategory,
                order: 0,
                isPinned: false
            )
            
            UserDefaults.standard.set(selectedCategory, forKey: Constants.categoryVcLastSelectedCategoryKey)
            
            trackerStore.createTracker(from: newTracker)
            NotificationCenter.default.post(name: .createdTracker, object: newTracker)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmojiIndex != nil
        let isColorSelected = selectedColorIndex != nil
        let isScheduleValid = trackerType == .irregularEvent || !selectedDays.isEmpty
        let isCategorySelected = isEditable || tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text?.isEmpty == false
        
        createButton.isEnabled = isNameValid && isEmojiSelected && isColorSelected && isScheduleValid && isCategorySelected
        createButton.backgroundColor = createButton.isEnabled ? Asset.ypBlack.color : Asset.ypLightGray.color
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        clearButton.isHidden = nameTextField.text?.isEmpty ?? true
        updateCreateButtonState()
    }
    
    @objc private func clearNameTextField() {
        nameTextField.text = ""
        clearButton.isHidden = true
        updateErrorLabelVisibility(isVisible: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func updateErrorLabelVisibility(isVisible: Bool) {
        errorLabel.isHidden = !isVisible
        errorLabelHeightConstraint.constant = isVisible ? 22 : 0
        UIView.animate(withDuration: 0.25) {
            self.contentView.layoutIfNeeded()
        }
    }
    
    func configure(with tracker: Tracker, daysText: String) {
        print("Конфигурация EventViewController. Исходные данные:")
        print("Трекер: \(tracker.name), ID: \(tracker.id), Тип: \(tracker.schedule.isEmpty ? ".irregularEvent" : ".habit"), Расписание: \(tracker.schedule)")
        
        self.currentTracker = tracker
        nameTextField.text = tracker.name
        
        daysLabel.text = daysText
        
        print("Конфигурация EventViewController завершена для трекера: \(tracker.name), Тип: \(tracker.schedule.isEmpty ? ".irregularEvent" : ".habit")")
        
        selectedEmojiIndex = emojis.firstIndex(of: tracker.emoji).map { IndexPath(item: $0, section: 0) }
        selectedColorIndex = colors.firstIndex(where: { $0?.hexString == tracker.color }).map { IndexPath(item: $0, section: 0) }
        selectedDays = tracker.schedule
        selectedDaysText = tracker.schedule.sorted(by: { $0.rawValue < $1.rawValue }).map { $0.abbreviation }.joined(separator: ", ")
        
        createButton.setTitle(isEditable ? "Сохранить" : Constants.eventVcCreateButtonTitle, for: .normal)
        
        daysContainerView.isHidden = trackerType != .habit || !isEditable
        daysContainerViewHeightConstraint?.constant = trackerType == .habit && isEditable ? 78 : 0
        
        updateCreateButtonState()
        tableView.reloadData()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EventViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        trackerType == .habit ? 2 : 1
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.eventVcTableViewCellId)
        configureCellAppearence(cell)
        
        if trackerType == .habit {
            if isEditable {
                guard let tracker = currentTracker else { return cell }
                configureHabitCell(cell, at: indexPath, tracker: tracker)
            } else {
                configureHabitCellForCreation(cell, at: indexPath)
            }
        } else if trackerType == .irregularEvent {
            if isEditable {
                configureIrregularEventCell(cell)
            } else {
                configureCategoryCell(cell, tracker: nil)
            }
        }
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    private func configureHabitCellForCreation(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            configureCellText(
                cell,
                mainText: Constants.eventVcCategoryTitle,
                mainTextColor: Asset.ypBlack.color,
                detailTextColor: Asset.ypGray.color
            )
        case 1:
            configureCellText(
                cell,
                mainText: Constants.scheduleVcTitle,
                detailText: selectedDaysText.isEmpty ? nil : selectedDaysText,
                mainTextColor: Asset.ypBlack.color,
                detailTextColor: Asset.ypGray.color
            )
        default:
            break
        }
    }
    
    private func configureCellAppearence(_ cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
    }
    
    private func configureTextAttributes(
        alignment: NSTextAlignment = .left,
        color: UIColor = Asset.ypBlack.color
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        return [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    private func configureCellText(
        _ cell: UITableViewCell,
        mainText: String,
        detailText: String? = nil,
        mainTextColor: UIColor = Asset.ypBlack.color,
        detailTextColor: UIColor = Asset.ypGray.color,
        alignment: NSTextAlignment = .right
    ) {
        cell.textLabel?.attributedText = NSAttributedString(
            string: mainText,
            attributes: configureTextAttributes(alignment: alignment, color: mainTextColor)
        )
        
        if let detailText = detailText {
            cell.detailTextLabel?.attributedText = NSAttributedString(
                string: detailText,
                attributes: configureTextAttributes(color: detailTextColor)
            )
        }
    }
    
    private func configureCategoryCell(_ cell: UITableViewCell, tracker: Tracker?) {
        let categoryText = isEditable ? tracker?.category : nil
        configureCellText(
            cell,
            mainText: Constants.eventVcCategoryTitle,
            detailText: categoryText,
            mainTextColor: Asset.ypBlack.color,
            detailTextColor: Asset.ypGray.color,
            alignment: .left
        )
    }
    
    private func configureHabitCell(
        _ cell: UITableViewCell,
        at indexPath: IndexPath,
        tracker: Tracker
    ) {
        switch indexPath.row {
        case 0:
            configureCategoryCell(cell, tracker: tracker)
        case 1:
            configureCellText(
                cell,
                mainText: Constants.scheduleVcTitle,
                detailText: selectedDaysText,
                mainTextColor: Asset.ypBlack.color,
                detailTextColor: Asset.ypGray.color
            )
        default:
            break
        }
    }
    
    private func configureIrregularEventCell(_ cell: UITableViewCell) {
        guard let tracker = currentTracker else { return }
        configureCategoryCell(cell, tracker: tracker)
    }
}
// MARK: - UITableViewDelegate
extension EventViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let categoryVC = CategoryViewController()
            categoryVC.currentCategory = tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text
            categoryVC.onCategorySelected = { [weak self] selectedCategory in
                guard let self = self else { return }
                self.updateCategoryCell(with: selectedCategory)
            }
            navigationController?.pushViewController(categoryVC, animated: true)
        } else if indexPath.row == 1 {
            view.endEditing(true)
            
            let scheduleVC = ScheduleViewController(selectedDays: Weekday.allCases.map {
                selectedDays.contains($0)
            })
            scheduleVC.onDaysSelected = { [weak self] selectedWeekdays in
                guard let self else { return }
                self.selectedDays = selectedWeekdays
                let selectedDayNames = selectedWeekdays.map { $0.abbreviation }
                self.selectedDaysText = selectedDayNames.joined(separator: ", ")
                self.updateCreateButtonState()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            present(scheduleVC, animated: true, completion: nil)
        }
    }
    
    private func updateCategoryCell(with category: String) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) {
            configureCellText(
                cell,
                mainText: Constants.eventVcCategoryTitle,
                detailText: category,
                mainTextColor: Asset.ypBlack.color,
                detailTextColor: Asset.ypGray.color)
        }
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDataSource
extension EventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.eventVcEmojiCollectionCellId,
                for: indexPath
            ) as? EventViewControllerCell else { return UICollectionViewCell() }
            
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            
            if indexPath == selectedEmojiIndex {
                cell.contentView.backgroundColor = Asset.ypLightGray.color
                cell.contentView.layer.cornerRadius = 16
                cell.contentView.layer.masksToBounds = true
            } else {
                cell.contentView.backgroundColor = .clear
            }
            
            return cell
            
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.eventVcColorCollectionCellId,
                for: indexPath
            ) as? EventViewControllerCell else { return UICollectionViewCell() }
            
            guard let color = colors[indexPath.item] else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath == selectedColorIndex
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let itemsPerRow: CGFloat = 6
        let sidePadding: CGFloat = 18
        let interItemSpacing: CGFloat = 5
        
        let totalPadding = sidePadding * 2 + interItemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - totalPadding
        let itemWidth = availableWidth / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == emojiCollectionView {
            selectedEmojiIndex = indexPath
        } else if collectionView == colorCollectionView {
            selectedColorIndex = indexPath
        }
        updateCreateButtonState()
        collectionView.reloadData()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

// MARK: - UITextFieldDelegate
extension EventViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.count > Constants.eventVcMaxNameLength {
            updateErrorLabelVisibility(isVisible: true)
            return false
        } else {
            updateErrorLabelVisibility(isVisible: false)
        }
        return true
    }
}
