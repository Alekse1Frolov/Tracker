//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CategoryViewModel()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.eventVcCategoryTitle
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.starPlaceholder.image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Asset.ypLightGray.color
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.categoryVcPlaceholderLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.categoryVcAddButtonTitle, for: .normal)
        button.backgroundColor = Asset.ypBlack.color
        button.setTitleColor(Asset.ypWhite.color, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.updatePaceholderVisibility()
        }
    }
    
    private func updatePaceholderVisibility() {
        let isEmpty = viewModel.isEmpty
        placeholderImageView.isHidden = !isEmpty
        placeholderLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController(viewModel: viewModel)
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
    
    private func setupView() {
        view.backgroundColor = Asset.ypWhite.color
        
        tableView.dataSource = self
        tableView.delegate = self
        
        [titleLabel, placeholderImageView, placeholderLabel, addCategoryButton].forEach { element in
            view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // placeholderImageView constraints
            placeholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // placeholderLabel constraints
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // addCategoryButton constraints
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.category(at: indexPath.row)
        return cell
    }
    
}
