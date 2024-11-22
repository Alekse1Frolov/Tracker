//
//  TrackerCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 04.11.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID)
    func uncompleteTracker(id: UUID)
    func toggleCompletion(for trackerID: UUID)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = Constants.trackersVcTrackerCellId
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.clipsToBounds = true
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.backgroundColor = Asset.ypWhite.color.withAlphaComponent(0.3)
        return label
    }()
    
    private let trackerCellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypWhite.color
        label.numberOfLines = 2
        return label
    }()
    
    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.backgroundColor = ProjectColors.TrackersColosSet.colorSelection5
        return view
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Asset.ypBlack.color
        return label
    }()
    
    private let plusButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.tintColor = Asset.ypWhite.color
        return button
    }()
    
    weak var delegate: TrackerCellDelegate?
    var trackerID: UUID?
    private var isCompleted: Bool = false {
        didSet {
            updateButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        [emojiLabel, trackerCellLabel].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            backView.addSubview(element)
        }
        
        [backView, counterLabel, plusButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            
            // backView constraint
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: 90),
            
            // emojiLabel constraint
            emojiLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            // trackerCellLabel constraint
            trackerCellLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            trackerCellLabel.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            trackerCellLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor),
            trackerCellLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            
            // counterLabel constraint
            counterLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // plusButton constraint
            plusButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func updateButton() {
        let image = isCompleted ? Asset.doneImage.image : UIImage(systemName: "plus")
        plusButton.setImage(image, for: .normal)
        plusButton.alpha = isCompleted ? 0.5 : 1.0
    }
    
    @objc private func plusButtonTapped() {
        guard let trackerID = trackerID else {
            assertionFailure("Missing TrackerID")
            return
        }
        delegate?.toggleCompletion(for: trackerID)
    }
    
    func configure(with tracker: Tracker) {
        emojiLabel.text = tracker.emoji
        trackerCellLabel.text = tracker.name
    }
    
    func configure(
        with tracker: Tracker,
        completed: Bool,
        completionCount: Int
    ) {
        emojiLabel.text = tracker.emoji
        trackerCellLabel.text = tracker.name
        
        let color = tracker.color
        
        backView.backgroundColor = color
        plusButton.backgroundColor = color
        counterLabel.text = "\(formatDay(completionCount))"
        
        self.trackerID = tracker.id
        self.isCompleted = completed
    }
    
    private func formatDay(_ count: Int) -> String {
        let remainderAfterDivisionBy10 = count % 10
        let remainderAfterDivisionBy100 = count % 100
        
        switch (remainderAfterDivisionBy10, remainderAfterDivisionBy100) {
        case (1, _) where remainderAfterDivisionBy100 != 11:
            return "\(count) день"
        case (2...4, _) where (remainderAfterDivisionBy100 < 10 || remainderAfterDivisionBy100 >= 20):
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
}
