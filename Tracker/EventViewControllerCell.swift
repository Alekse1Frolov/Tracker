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
        return label
    }()
    
    private let colorView: UIView = {
        let view = UIView()
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
            return view
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [colorView, emojiLabel].forEach { element in
            element.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(element)
        }
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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
        colorView.backgroundColor = color
        emojiLabel.text = ""
    }
}
