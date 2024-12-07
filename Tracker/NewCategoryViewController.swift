//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Aleksei Frolov on 04.12.2024.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: NewCategoryViewModel
    private var errorLabelHeightConstraint: NSLayoutConstraint!
    var onCategoryCreated: (() -> Void)?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.newCategoryVcTitle
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.newCategoryVcPlaceholder
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
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.eventVcMaxNameLengthErrorText
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = Asset.ypRed.color
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.scheduleVcReadyButtonTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Constants.eventVcClearButtonSystemName), for: .normal)
        button.tintColor = Asset.ypGray.color
        button.addTarget(self, action: #selector(clearNameTextField), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = NewCategoryViewModel(categoryViewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        setupClearButton()
        
        nameTextField.delegate = self
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        [titleLabel, nameTextField, errorLabel, readyButton].forEach { element in
            view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            errorLabelHeightConstraint,
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func clearNameTextField() {
        nameTextField.text = ""
        clearButton.isHidden = true
        updateErrorLabelVisibility(isVisible: false)
        updateReadyButtonState()
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
    
    func updateErrorLabelVisibility(isVisible: Bool) {
        errorLabel.isHidden = !isVisible
        errorLabelHeightConstraint.constant = isVisible ? 22 : 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupObservers() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func updateReadyButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        
        readyButton.isEnabled = isNameValid
        readyButton.backgroundColor = readyButton.isEnabled ? Asset.ypBlack.color : Asset.ypGray.color
    }
    
    @objc private func textFieldDidChange() {
        let isTextValid = !(nameTextField.text?.isEmpty ?? true)
        readyButton.isEnabled = isTextValid
        readyButton.backgroundColor = isTextValid ? .black : .gray
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        clearButton.isHidden = nameTextField.text?.isEmpty ?? true
        updateReadyButtonState()
    }
    
    @objc private func readyButtonTapped() {
        guard let category = nameTextField.text, !category.isEmpty else { return }
        
        let categoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)
        let newCategory = TrackerCategory(title: category, trackers: [])
        categoryStore.createCategory(from: newCategory)
        
        viewModel.addCategory(category)
        onCategoryCreated?()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
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
