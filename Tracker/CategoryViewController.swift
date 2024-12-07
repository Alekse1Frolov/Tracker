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
    private var selectedIndexPath: IndexPath?
    var onCategorySelected: ((String) -> Void)?
    
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
        setupBindings()
        viewModel.loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
        tableView.reloadData()
        updatePaceholderVisibility()
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
        if viewModel.numberOfCategories == 0 || selectedIndexPath == nil {
            let newCategoryVC = NewCategoryViewController(viewModel: viewModel)
            newCategoryVC.onCategoryCreated = { [weak self] in
                guard let self = self else { return }
                self.viewModel.loadCategories()
                self.tableView.reloadData()
                self.updatePaceholderVisibility()
            }
            navigationController?.pushViewController(newCategoryVC, animated: true)
        } else {
            guard let selectedIndexPath = selectedIndexPath else { return }
            let selectedCategory = viewModel.category(at: selectedIndexPath.row)
            onCategorySelected?(selectedCategory)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupView() {
        view.backgroundColor = Asset.ypWhite.color
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        
        [titleLabel, placeholderImageView, placeholderLabel,
         tableView, addCategoryButton].forEach { element in
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
            
            // tableView constraints
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            
            // addCategoryButton constraints
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfCategories
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = viewModel.category(at: indexPath.row)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17,weight: .regular)
        cell.textLabel?.textColor = Asset.ypBlack.color
        cell.backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
        
        tableView.separatorStyle = .none
        
        configureRoundedCorners(for: cell, at: indexPath)
        
        cell.accessoryType = (indexPath == selectedIndexPath) ? .checkmark : .none
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPAth: IndexPath
    ) {
        selectedIndexPath = indexPAth
        tableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let separatorHeight: CGFloat = 0.5
        let separatorColor = Asset.ypGray.color
        
        cell.subviews.forEach { subview in
            if subview.tag == 444 { subview.removeFromSuperview() }
        }
        
        if indexPath.row != viewModel.numberOfCategories - 1 {
            let separator = UIView()
            separator.backgroundColor = separatorColor
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.tag = 444
            cell.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: separatorHeight)
            ])
        }
    }
    
    private func configureRoundedCorners(
        for cell: UITableViewCell,
        at indexPath: IndexPath
    ) {
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.layer.masksToBounds = false
        
        let rowCount = viewModel.numberOfCategories
        
        if rowCount == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        } else if indexPath.row == rowCount - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        }
    }
}
