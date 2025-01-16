//
//  EditableTracker.swift
//  Tracker
//
//  Created by Aleksei Frolov on 18.12.2024.
//

import Foundation

struct EditableTracker {
    let tracker: Tracker
    let isEditable: Bool
    let currentCategory: String
    var isPinned: Bool { currentCategory == Constants.categoryVcPinnedCategoryTitle }
}
