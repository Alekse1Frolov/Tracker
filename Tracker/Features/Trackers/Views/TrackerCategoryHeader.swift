//
//  TrackerCategoryHeader.swift
//  Tracker
//
//  Created by Aleksei Frolov on 10.11.2024.
//

import UIKit

final class TrackerCategoryHeader: UICollectionReusableView {
    static let reuseID = Constants.trackersVcTrackerCategoryHeaderId
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = Asset.ypBlack.color
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with title: String) {
        textLabel.text = title
    }
}
