//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import Foundation

final class CategoryViewModel {
    private var categories: [String] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    var onCategoriesUpdated: (() -> Void)?
    var isEmpty: Bool {
        return categories.isEmpty
    }
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    func category(at index: Int) -> String {
        return categories[index]
    }
    
    func addCategory(_ category: String) {
        categories.append(category)
    }
    
    func loadCategories() {
        // TO DO
    }
}
