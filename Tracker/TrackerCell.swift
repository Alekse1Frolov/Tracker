//
//  TrackerCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 04.11.2024.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrakerCell"
    
    private let trackerCellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ProjectColors.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = ProjectColors.blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(trackerCellLabel)
        contentView.addSubview(plusButton)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            trackerCellLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            trackerCellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            trackerCellLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -12),
            
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker) {
        trackerCellLabel.text = tracker.name
    }
}
