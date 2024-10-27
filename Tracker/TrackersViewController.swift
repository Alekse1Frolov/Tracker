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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ProjectColors.white
        
        setupNavigationBar()
        setupLayout()
    }
    
    private func setupNavigationBar() {
        
        let addButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addButtonTapped))
        addButtonItem.tintColor = ProjectColors.black
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.leftBarButtonItem = addButtonItem
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    @objc private func addButtonTapped() {
        // TO DO
        print("Add button tapped")
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // searchBar constraints
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
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
