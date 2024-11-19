//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.11.2024.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    
    static let reuseIdentifier = Constants.scheduleVcCellId
    
    // MARK: - UI Elements
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = ProjectColors.blue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        
        [dayLabel, switchView].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            // dayLabel constraints
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // switchView constraints
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(
        with day: String,
        isSelected: Bool,
        tag: Int,
        target: Any?,
        action: Selector
    ) {
        dayLabel.text = day.capitalized
        switchView.isOn = isSelected
        switchView.tag = tag
        switchView.addTarget(target, action: action, for: .valueChanged)
    }
}
