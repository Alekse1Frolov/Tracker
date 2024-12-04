//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import Foundation

final class NewCategoryViewModel {
    private let categoryViewModel: CategoryViewModel
    
    init(categoryViewModel: CategoryViewModel) {
        self.categoryViewModel = categoryViewModel
    }
    
    func addCategory(_ category: String) {
        categoryViewModel.addCategory(category)
    }
}
