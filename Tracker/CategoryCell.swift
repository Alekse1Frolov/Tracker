//
//  CategoryCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 12.12.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"
    
    func configure(with categoryName: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        textLabel?.text = categoryName
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel?.textColor = Asset.ypBlack.color
        backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
        accessoryType = isSelected ? .checkmark : .none
        
        configureRoundedCorners(isFirst: isFirst, isLast: isLast)
    }
    
    private func configureRoundedCorners(isFirst: Bool, isLast: Bool) {
        layer.cornerRadius = 0
        layer.maskedCorners = []
        layer.masksToBounds = false
        
        if isFirst {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        layer.masksToBounds = true
    }
}
