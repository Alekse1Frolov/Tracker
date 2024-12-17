//
//  ContextMenuManager.swift
//  Tracker
//
//  Created by Aleksei Frolov on 17.12.2024.
//

import UIKit

final class ContextMenuManager: NSObject {
    // MARK: - UI Elements
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let contextMenuView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 13
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ContextMenuOptionCell"
        )
        tableView.alpha = 0.0
        return tableView
    }()
    
    // MARK: - Properties
    private weak var window: UIWindow?
    private var options: [String]
    private var onOptionSelected: ((Int) -> Void)?
    
    // MARK: - Init
    init(options: [String]) {
        self.options = options
        self.window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        super.init()
        contextMenuView.delegate = self
        contextMenuView.dataSource = self
        setupBlurDismissGesture()
    }
    
    private func displayOptionsMenu(under frame: CGRect, options: [String]) {
        let menuWidth: CGFloat = 250
        let menuHeight: CGFloat = CGFloat(options.count * 48)
        let adjustedY = frame.maxY + 12
        
        guard let window = window else { return }
        let menuX = min(frame.minX, window.bounds.width - menuWidth - 16)
        let menuFrame = CGRect(x: menuX, y: adjustedY, width: menuWidth, height: menuHeight)
        
        contextMenuView.frame = menuFrame
        contextMenuView.reloadData()
        
        if contextMenuView.superview == nil {
            window.addSubview(contextMenuView)
            UIView.animate(withDuration: 0.2) {
                self.contextMenuView.alpha = 1.0
            }
        }
    }
    
    func showContextMenu<T>(
        under frame: CGRect,
        options: [String],
        data: T?,
        onSelect: @escaping (Int, T) -> Void
    ) {
        guard let window = window else { return }
        self.onOptionSelected = { index in
            if let data = data {
                onSelect(index, data)
            }
        }
        
        addBlurEffect(excludingFrame: frame, in: window)
        displayOptionsMenu(under: frame, options: options)
    }
    
    private func addBlurEffect(excludingFrame frame: CGRect, in window: UIWindow) {
        if blurView.superview == nil {
            window.addSubview(blurView)
            blurView.frame = window.bounds
            blurView.layer.mask = createMaskExcludingFrame(frame, in: window)
            UIView.animate(withDuration: 0.2) {
                self.blurView.alpha = 4.0
            }
        }
    }
    
    func hideContextMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView.alpha = 0.0
            self.contextMenuView.alpha = 0.0
        }, completion: { _ in
            self.blurView.removeFromSuperview()
            self.contextMenuView.removeFromSuperview()
        })
    }
    
    private func setupBlurDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blurTapped))
        blurView.addGestureRecognizer(tapGesture)
    }
    
    private func createMaskExcludingFrame(_ excludedFrame: CGRect, in view: UIView) -> CALayer {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: view.bounds)
        
        let excludedPath = UIBezierPath(roundedRect: excludedFrame, cornerRadius: 14)
        path.append(excludedPath)
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        return maskLayer
    }
    
    @objc private func blurTapped() {
        hideContextMenu()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ContextMenuManager: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        options.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextMenuOptionCell", for: indexPath)
        
        cell.textLabel?.removeFromSuperview()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = options[indexPath.row]
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = (indexPath.row == options.count - 1)
        ? Asset.ypRed.color
        : .label
        
        cell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        cell.backgroundColor = .systemBackground
        cell.selectionStyle = .none
        
        if indexPath.row == options.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: tableView.bounds.width,
                bottom: 0,
                right: 0
            )
        } else {
            cell.separatorInset = .zero
        }
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        hideContextMenu()
        onOptionSelected?(indexPath.row)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        48
    }
}
