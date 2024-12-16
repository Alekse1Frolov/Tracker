//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import Foundation

final class NewCategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)) {
        self.categoryStore = categoryStore
    }
    
    func saveCategory(title: String, originalTitle: String?) {
        if let originalTitle = originalTitle {
            _ = categoryStore.updateCategory(oldTitle: originalTitle, newTitle: title)
        } else {
            categoryStore.createCategory(from: TrackerCategory(title: title, trackers: []))
        }
    }
}
