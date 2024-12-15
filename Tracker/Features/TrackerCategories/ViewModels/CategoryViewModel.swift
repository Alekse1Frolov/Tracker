//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Aleksei Frolov on 03.12.2024.
//

import Foundation

final class CategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    var onCategoriesUpdated: (() -> Void)?
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    var numberOfCategories: Int {
        categories.count
    }
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(context: CoreDataStack.shared.mainContext)) {
        self.categoryStore = categoryStore
    }
    
    func categoryName(at indexPath: IndexPath) -> String {
        categories[indexPath.row].title
    }
    
    func isCategorySelected(at indexPath: IndexPath, currentCategory: String?) -> Bool {
        guard let currentCategory = currentCategory else { return false }
        return categories[indexPath.row].title == currentCategory
    }
    
    func category(at index: Int) -> String {
        categories[index].title
    }
    
    func indexOfCategory(named categoryName: String) -> Int? {
        categories.firstIndex { $0.title == categoryName }
    }
    
    func addCategory(_ title: String) {
        categoryStore.createCategory(from: TrackerCategory(title: title, trackers: []))
        loadCategories()
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        _ = categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
        loadCategories()
    }
    
    func loadCategories() {
        categories = categoryStore.fetchCategories().map { TrackerCategory(coreDataCategory: $0) }
    }
    
    func removeCategory(at index: Int) {
        let title = categories[index].title
        categoryStore.deleteCategory(byTitle: title)
        loadCategories()
    }
}
