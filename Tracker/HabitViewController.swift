//
//  HabitViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 05.11.2024.
//

import UIKit

final class HabitViewController: UIViewController {
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let emojis = MockData.emojis
    private let colors = MockData.trackersColors
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = ProjectColors.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.backgroundColor = ProjectColors.lightGray?.withAlphaComponent(0.3)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = padding
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = ProjectColors.white
        tableView.separatorColor = ProjectColors.gray
        tableView.separatorInset = .zero
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
        private let emojiLabel: UILabel = {
            let label = UILabel()
            label.text = "Emoji"
            label.font = .systemFont(ofSize: 19, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
        private let emojiCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 5
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.isScrollEnabled = false
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
    
        private let colorLabel: UILabel = {
            let label = UILabel()
            label.text = "Цвет"
            label.font = .systemFont(ofSize: 19, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
        private let colorCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 5
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(ProjectColors.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = ProjectColors.red?.cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(ProjectColors.gray, for: .normal)
        button.backgroundColor = ProjectColors.lightGray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ProjectColors.white
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupLayout()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        view.addSubview(tableView)
    }
    
        private func setupCollectionView() {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.register(HabitViewCell.self, forCellWithReuseIdentifier: "emojiCell")
    
            colorCollectionView.dataSource = self
            colorCollectionView.delegate = self
            colorCollectionView.register(HabitViewCell.self, forCellWithReuseIdentifier: "colorCell")
        }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(buttonStackView)
        buttonStackView.addSubview(cancelButton)
        buttonStackView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // nameTextField constraints
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // emojiLabel constraints
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            
            // emojiCollectionView constraints
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            // colorLabel constraints
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            
            // colorCollectionView constraints
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: emojiCollectionView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: emojiCollectionView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalTo: emojiCollectionView.heightAnchor),
            
            // buttonStackView constraints
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
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
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text, !trackerName.isEmpty else {
            print("Трекер не создан: не введено имя")
            return
        }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: ProjectColors.TrackersColosSet.colorSelection5,
            emoji: "🌱",
            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        )
        print("Создан трекер:", newTracker)
        NotificationCenter.default.post(name: .createdTracker, object: newTracker)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = ProjectColors.lightGray?.withAlphaComponent(0.3)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
        case 1:
            cell.textLabel?.text = "Расписание"
        default:
            break
        }
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
// MARK: - UITableViewDelegate
extension HabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController(selectedDays: Array(repeating: false, count: 7))
            scheduleVC.onDaysSelected = { [weak self] selectedDays in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            present(scheduleVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HabitViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? HabitViewCell else { return UICollectionViewCell() }
            
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji)
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? HabitViewCell else { return UICollectionViewCell() }
            
            let color = colors[indexPath.item]
            cell.configure(with: color)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colorCollectionView {
            return CGSize(width: 40, height: 40)
        } else {
            let side = (view.frame.width - 64) / 6
            return CGSize(width: side, height: side)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == colorCollectionView {
            return UIEdgeInsets(top: 30, left: 28, bottom: 30, right: 28)
        } else {
            return UIEdgeInsets(top: 31, left: 18, bottom: 24, right: 18)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == colorCollectionView {
            return 17
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == colorCollectionView {
            return 12
        } else {
            return 0
        }
    }
}

