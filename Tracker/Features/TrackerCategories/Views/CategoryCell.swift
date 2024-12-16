//
//  CategoryCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 12.12.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = Constants.categoryVcCategoryCell
    private var separator: UIView?
    
    func configure(
        with categoryName: String,
        isSelected: Bool,
        isSingle: Bool,
        isFirst: Bool,
        isLast: Bool
    ) {
        textLabel?.text = categoryName
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel?.textColor = Asset.ypBlack.color
        backgroundColor = Asset.ypLightGray.color.withAlphaComponent(0.3)
        accessoryType = isSelected ? .checkmark : .none
        
        configureRoundedCorners(isFirst: isFirst, isLast: isLast, isSingle: isSingle)
        configureSeparator(isLast: isLast)
    }
    
    private func configureRoundedCorners(isFirst: Bool, isLast: Bool, isSingle: Bool) {
        layer.cornerRadius = 0
        layer.maskedCorners = []
        layer.masksToBounds = false
        
        if isSingle {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else if isFirst {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        layer.masksToBounds = true
    }
    
    private func configureSeparator(isLast: Bool) {
        separator?.removeFromSuperview()
        
        guard !isLast else { return }
        
        let separatorHeight: CGFloat = 0.5
        let separatorColor = Asset.ypGray.color
        
        let newSeparator = UIView()
        newSeparator.backgroundColor = separatorColor
        newSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newSeparator)
        
        NSLayoutConstraint.activate([
            newSeparator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            newSeparator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            newSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            newSeparator.heightAnchor.constraint(equalToConstant: separatorHeight)
        ])
        
        self.separator = newSeparator
    }
}
