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
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
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
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
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
        button.layer.borderWidth = 1
        button.layer.borderColor = Asset.ypRed.color.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.eventVcCreateButtonTitle, for: .normal)
        button.setTitleColor(Asset.ypGray.color, for: .normal)
        button.backgroundColor = Asset.ypLightGray.color
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
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        setupLayout()
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupScrollViewContent()
        setupClearButton()
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
        
        [nameTextField, errorLabel, tableView, emojiLabel, emojiCollectionView,
         colorLabel, colorCollectionView].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // nameTextField constraints
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
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
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            
            // emojiCollectionView constraints
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
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
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text, !trackerName.isEmpty else { return }
        guard let selectedEmojiIndex = selectedEmojiIndex else { return }
        guard let selectedColorIndex = selectedColorIndex else { return }
        
        if trackerType == .habit && selectedDays.isEmpty {
                showError(message: "Необходимо выбрать хотя бы один день недели.")
                return
            }

        let selectedEmoji = emojis[selectedEmojiIndex.item]
        let selectedColor = colors[selectedColorIndex.item]
  //      let selectedWeekdays = Weekday.allCases.filter { selectedDays.contains($0) }

        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays
        )

        NotificationCenter.default.post(name: .createdTracker, object: newTracker)
        dismiss(animated: true, completion: nil)
    }

    private func showError(message: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmojiIndex != nil
        let isColorSelected = selectedColorIndex != nil
        let isScheduleValid = trackerType == .irregularEvent || !selectedDays.isEmpty

        createButton.isEnabled = isNameValid && isEmojiSelected && isColorSelected && isScheduleValid
        createButton.backgroundColor = createButton.isEnabled ? Asset.ypBlue.color : Asset.ypLightGray.color
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
            configureHabitCell(cell, at: indexPath)
        } else if trackerType == . irregularEvent {
            configureIrregularEventCell(cell)
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
        detailTextColor: UIColor = .gray,
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
    
    private func configureCategoryCell(_ cell: UITableViewCell) {
        configureCellText(
            cell,
            mainText: Constants.eventVcCategoryTitle,
            mainTextColor: Asset.ypBlack.color
        )
    }
    
    private func configureHabitCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            configureCategoryCell(cell)
        case 1:
            configureCellText(
                cell,
                mainText: Constants.scheduleVcTitle,
                detailText: selectedDaysText,
                mainTextColor: Asset.ypBlack.color,
                detailTextColor: .gray
            )
        default:
            break
        }
    }
    
    private func configureIrregularEventCell(_ cell: UITableViewCell) {
        configureCategoryCell(cell)
    }
}
// MARK: - UITableViewDelegate
extension EventViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
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
            
            let color = colors[indexPath.item]
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
