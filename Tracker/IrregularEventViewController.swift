//
//  IrregularEventViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 05.11.2024.
//

import UIKit

final class IrregularEventViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.tintColor = ProjectColors.black
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
        tableView.separatorColor = ProjectColors.lightGray
        tableView.separatorInset = .zero
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //    private let emojiLabel: UILabel = {
    //        let label = UILabel()
    //        label.text = "Emoji"
    //        label.font = .systemFont(ofSize: 19, weight: .bold)
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //        return label
    //    }()
    //
    //    private let emojiCollectionView: UICollectionView = {
    //        let layout = UICollectionViewFlowLayout()
    //        layout.minimumLineSpacing = 5
    //        layout.minimumInteritemSpacing = 5
    //        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    //        collectionView.isScrollEnabled = false
    //        collectionView.translatesAutoresizingMaskIntoConstraints = false
    //        return collectionView
    //    }()
    //
    //    private let colorLabel: UILabel = {
    //        let label = UILabel()
    //        label.text = "Цвет"
    //        label.font = .systemFont(ofSize: 19, weight: .bold)
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //        return label
    //    }()
    //
    //    private let colorCollectionView: UICollectionView = {
    //        let layout = UICollectionViewFlowLayout()
    //        layout.scrollDirection = .vertical
    //        layout.minimumLineSpacing = 5
    //        layout.minimumInteritemSpacing = 5
    //        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    //        collectionView.translatesAutoresizingMaskIntoConstraints = false
    //        return collectionView
    //    }()
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ProjectColors.white
        setupTableView()
        //setupCollectionView()
        setupLayout()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        view.addSubview(tableView)
    }
    
    //    private func setupCollectionView() {
    //        emojiCollectionView.dataSource = self
    //        emojiCollectionView.delegate = self
    //        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
    //
    //        colorCollectionView.dataSource = self
    //        colorCollectionView.delegate = self
    //        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
    //    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        //  view.addSubview(emojiLabel)
        //  view.addSubview(emojiCollectionView)
        //  view.addSubview(colorLabel)
        //  view.addSubview(colorCollectionView)
        view.addSubview(buttonStackView)
        buttonStackView.addSubview(cancelButton)
        buttonStackView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // nameTextField constraints
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // emojiLabel constraints
            // emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            // emojiLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            
            // emojiCollectionView constraints
            // emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            // emojiCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            // emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            // colorLabel constraints
            // colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            // colorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            
            // colorCollectionView constraints
            // colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            // colorCollectionView.leadingAnchor.constraint(equalTo: emojiCollectionView.leadingAnchor),
            // colorCollectionView.trailingAnchor.constraint(equalTo: emojiCollectionView.trailingAnchor),
            // colorCollectionView.heightAnchor.constraint(equalTo: emojiCollectionView.heightAnchor),
            
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
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createButtonTapped() {
        // TO DO
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension IrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = ProjectColors.lightGray?.withAlphaComponent(0.3)
        cell.textLabel?.text = "Категория"
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension IrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TO DO
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
//extension IrregularEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 18
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView == emojiCollectionView ? "emojiCell" : "colorCell", for: indexPath)
//        cell.layer.cornerRadius = 8
//        cell.layer.masksToBounds = true
//        cell.backgroundColor = collectionView == emojiCollectionView ? .systemYellow : ProjectColors.blue
//        return cell
//    }
//}
//
// MARK: - UICollectionViewDelegateFlowLayout
//extension IrregularEventViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let side = (view.frame.width - 64) / 6
//        return CGSize(width: side, height: side)
//    }
//}

