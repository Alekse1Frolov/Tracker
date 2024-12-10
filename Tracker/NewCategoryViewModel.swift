//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import Foundation

final class NewCategoryViewModel {
    private let categoryViewModel: CategoryViewModel
    
    var numberOfCategories: Int {
        return categoryViewModel.numberOfCategories
    }
    
    init(categoryViewModel: CategoryViewModel) {
        self.categoryViewModel = categoryViewModel
    }
    
    func addCategory(_ category: String) {
        categoryViewModel.addCategory(category)
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        categoryViewModel.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
    }
    
    func category(at index: Int) -> String {
        return categoryViewModel.category(at: index)
    }
}
