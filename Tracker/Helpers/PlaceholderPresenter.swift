//
//  PlaceholderPresenter.swift
//  Tracker
//
//  Created by Aleksei Frolov on 30.12.2024.
//

import UIKit

final class PlaceholderPresenter {
    private weak var imageView: UIImageView?
    private weak var label: UILabel?
    
    init(imageView: UIImageView, label: UILabel) {
        self.imageView = imageView
        self.label = label
    }
    
    func showPlaceholder(image: UIImage, text: String) {
        print("Показываем плейсхолдер с текстом: \(text)")
        imageView?.image = image
        label?.text = text
        imageView?.isHidden = false
        label?.isHidden = false
        print("Плейсхолдер видим: \(imageView?.isHidden == false && label?.isHidden == false)")
    }
    
    func hidePlaceholder() {
        print("Скрываем плейсхолдер")
        imageView?.isHidden = true
        label?.isHidden = true
        print("Плейсхолдер скрыт: \(imageView?.isHidden == true && label?.isHidden == true)")
    }
}
