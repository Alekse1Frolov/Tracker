//
//  EventViewControllerCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 06.11.2024.
//

import UIKit

final class EventViewControllerCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
        contentView.backgroundColor = .clear
    }
    
    func configure(with color: UIColor) {
        contentView.backgroundColor = color
        emojiLabel.text = ""
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
}