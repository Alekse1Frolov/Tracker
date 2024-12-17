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
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let contextMenuView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContextMenuOptionCell")
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
    
    func showContextMenu(under frame: CGRect, onSelect: @escaping (Int) -> Void) {
        guard let window = window else { return }
        self.onOptionSelected = onSelect
        
        if blurView.superview == nil {
            window.addSubview(blurView)
            blurView.frame = window.bounds
            blurView.layer.mask = createMaskExcludingFrame(frame, in: window)
            
            UIView.animate(withDuration: 0.2) {
                self.blurView.alpha = 1.0
            }
        }
        
        let menuWidth: CGFloat = 200
        let menuHeight: CGFloat = CGFloat(options.count * 48)
        let adjustedY = frame.maxY + 12
        
        let menuX = min(frame.minX, window.bounds.width - menuWidth - 16)
        let menuFrame = CGRect(x: menuX, y: adjustedY, width: menuWidth, height: menuHeight)
        
        if contextMenuView.superview == nil {
            window.addSubview(contextMenuView)
            contextMenuView.frame = menuFrame
            UIView.animate(withDuration: 0.2) {
                self.contextMenuView.alpha = 1.0
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextMenuOptionCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = (indexPath.row == options.count - 1) ? .systemRed : .label
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideContextMenu()
        onOptionSelected?(indexPath.row)
    }
}
