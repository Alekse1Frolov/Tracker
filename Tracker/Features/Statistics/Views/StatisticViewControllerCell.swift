//
//  StatisticViewControllerCell.swift
//  Tracker
//
//  Created by Aleksei Frolov on 22.12.2024.
//

import UIKit

final class StatisticTableViewCell: UITableViewCell {

    private let borderLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    
    static let reuseIdentifier = "StatisticTableViewCell"
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = Asset.ypBlack.color
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Asset.ypBlack.color
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        layer.cornerRadius = 16
        
        configure()
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        countLabel.text = ""
        titleLabel.text = ""
    }
    
    func setCount(count: Int) {
        countLabel.text = String(count)
    }
    
    func setTitle(text: String?) {
        titleLabel.text = text
    }
    
    private func setupGradientBorder() {
        gradientLayer.removeFromSuperlayer()
        borderLayer.removeFromSuperlayer()
        
        gradientLayer.colors = [
            UIColor(rgb: 0x007BFA).cgColor,
            UIColor(rgb: 0x46E69D).cgColor,
            UIColor(rgb: 0xFD4C49).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16
        
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 16
        ).cgPath
        borderLayer.lineWidth = 2
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = borderLayer
        
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 16
        ).cgPath
    }
    
    private func configure() {
        [countLabel, titleLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -7),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
}
