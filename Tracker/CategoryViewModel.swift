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
    
    func indexOfCategory(named categoryName: String) -> Int? {
        return categories.firstIndex(of: categoryName)
    }
    
    func addCategory(_ category: String) {
        categories.append(category)
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
            if let index = categories.firstIndex(of: oldTitle) {
                categories[index] = newTitle
                onCategoriesUpdated?()
            }
        }
    
    func loadCategories() {
        let categoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)
        let fetchedCategories = categoryStore.fetchCategories()
        categories = fetchedCategories.map { $0.title ?? "Без категории" }
    }
    
    func removeCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        categories.remove(at: index)
    }
}
