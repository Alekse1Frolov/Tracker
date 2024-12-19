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
    private var contextMenuManager: ContextMenuManager?
    var onCategorySelected: ((String) -> Void)?
    var currentCategory: String?
    
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
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
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
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        
        setupView()
        setupBindings()
        viewModel.loadCategories()
        contextMenuManager = ContextMenuManager(options: ["Редактировать", "Удалить"])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if currentCategory == nil {
            currentCategory = UserDefaults.standard.string(forKey: Constants.categoryVcLastSelectedCategoryKey)
        }
        
        viewModel.loadCategories()
        tableView.reloadData()
        updatePaceholderVisibility()
        updateSelectedIndexPath()
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
    
    private func updateSelectedIndexPath() {
        guard let currentCategory = currentCategory else {
            selectedIndexPath = nil
            return
        }
        selectedIndexPath = viewModel.indexOfCategory(named: currentCategory).map {
            IndexPath(row: $0, section: 0)
        }
    }
    
    private func presentEditCategoryScreen(for categoryName: String) {
        let newCategoryViewModel = NewCategoryViewModel()
        let editCategoryVC = NewCategoryViewController(viewModel: newCategoryViewModel)
        editCategoryVC.setEditingMode(with: categoryName)
        
        editCategoryVC.onCategoryEdited = { [weak self] newTitle in
            guard let self = self else { return }
            self.viewModel.updateCategory(oldTitle: categoryName, newTitle: newTitle)
        }
        
        navigationController?.pushViewController(editCategoryVC, animated: true)
    }
    
    private func showDeleteConfirmation(for category: String, at index: Int) {
        AlertService.showDeleteConfirmationAlert(
            title: Constants.categoryVcDeleteConfirmationAlertTitle,
            onDelete: { [weak self] in
                guard let self = self else { return }
                self.viewModel.removeCategory(at: index)
                self.tableView.reloadData()
                self.updatePaceholderVisibility()
            },
            presenter: self
        )
    }
    
    @objc private func longPressOnCategory(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        if gesture.state == .began {
            let cell = tableView.cellForRow(at: indexPath)
            let cellFrame = tableView.convert(cell?.frame ?? .zero, to: view.window)
            let options = ["Редактировать", "Удалить"]
            let categoryName = viewModel.category(at: indexPath.row)
            
            contextMenuManager?.showContextMenu(
                under: cellFrame,
                options: options,
                data: categoryName
            ) { [weak self] selectedIndex, category in
                guard let self = self else { return }
                switch selectedIndex {
                case 0:
                    self.presentEditCategoryScreen(for: category)
                case 1:
                    self.showDeleteConfirmation(for: category, at: indexPath.row)
                default:
                    break
                }
            }
        }
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController(viewModel: NewCategoryViewModel())
        newCategoryVC.onCategoryCreated = { [weak self] in
            guard let self = self else { return }
            self.viewModel.loadCategories()
            self.tableView.reloadData()
            self.updatePaceholderVisibility()
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
    
    private func setupView() {
        view.backgroundColor = Asset.ypWhite.color
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCategory))
        tableView.addGestureRecognizer(longPressGesture)
        
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier, for: indexPath
        ) as? CategoryCell else {
            assertionFailure("Failed to dequeue CategoryCell")
            return UITableViewCell()
        }
        
        let categoryName = viewModel.categoryName(at: indexPath)
        let isSelected = indexPath == selectedIndexPath
        
        cell.configure(
            with: categoryName,
            isSelected: isSelected,
            isSingle: viewModel.numberOfCategories == 1,
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == viewModel.numberOfCategories - 1
        )
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        selectedIndexPath = indexPath
        let selectedCategory = viewModel.categoryName(at: indexPath)
        onCategorySelected?(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
}
