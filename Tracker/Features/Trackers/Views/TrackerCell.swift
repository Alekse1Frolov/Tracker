//
//  TrackerCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 04.11.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func toggleCompletion(for trackerID: UUID)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = Constants.trackersVcTrackerCellId
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.clipsToBounds = true
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = Asset.ypWhite.color.withAlphaComponent(0.3)
        return view
    }()
    
    private let trackerCellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypWhite.color
        label.numberOfLines = 2
        label.textAlignment = .left
        label.baselineAdjustment = .alignBaselines
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
        button.setImage(UIImage(systemName: Constants.trackerCellPlusButtonSystemName), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.tintColor = Asset.ypWhite.color
        return button
    }()
    
    private let pinIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pinIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var backViewFrame: CGRect {
        return backView.frame
    }
    
    var counterLabelText: String? {
        return counterLabel.text
    }
    
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
        
        [emojiBackgroundView, trackerCellLabel, pinIcon].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            backView.addSubview(element)
        }
        
        [backView, counterLabel, plusButton].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        setupEmoji()
        
        NSLayoutConstraint.activate([
            
            // backView constraint
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: 90),
            
            // emojiBackgroundView constraint
            emojiBackgroundView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            
            // trackerCellLabel constraint
            trackerCellLabel.leadingAnchor.constraint(equalTo: emojiBackgroundView.leadingAnchor),
            trackerCellLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            trackerCellLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -12),
            trackerCellLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiBackgroundView.bottomAnchor, constant: 8),
            
            // counterLabel constraint
            counterLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // plusButton constraint
            plusButton.centerYAnchor.constraint(equalTo: counterLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            
            // pinView constraint
            pinIcon.topAnchor.constraint(equalTo: backView.topAnchor, constant: 18),
            pinIcon.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -12),
            pinIcon.heightAnchor.constraint(equalToConstant: 12),
            pinIcon.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupEmoji() {
        emojiBackgroundView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(lessThanOrEqualTo: emojiBackgroundView.heightAnchor, multiplier: 0.9),
            emojiLabel.widthAnchor.constraint(lessThanOrEqualTo: emojiBackgroundView.widthAnchor, multiplier: 0.9)
        ])
    }
    
    private func updateButton() {
        let image = isCompleted ? Asset.doneImage.image : UIImage(systemName: Constants.trackerCellPlusButtonSystemName)
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
    
    func configure(
        with tracker: Tracker,
        completed: Bool,
        completionCount: Int,
        isPinned: Bool
    ) {
        emojiLabel.text = tracker.emoji
        trackerCellLabel.text = tracker.name
        
        if let color = UIColor(hex: tracker.color) {
            backView.backgroundColor = color
            plusButton.backgroundColor = color
        } else {
            backView.backgroundColor = Asset.ypRed.color
            plusButton.backgroundColor = Asset.ypRed.color
        }
        
        counterLabel.text = "\(formatDay(completionCount))"
        
        self.trackerID = tracker.id
        self.isCompleted = completed
        
        pinIcon.isHidden = !isPinned
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
