//
//  Array+Extensions.swift
//  Tracker
//
//  Created by Aleksei Frolov on 05.01.2025.
//

import Foundation

extension Array {
    func partitioned(by condition: (Element) -> Bool) -> (matches: [Element], nonMatches: [Element]) {
        var matches: [Element] = []
        var nonMatches: [Element] = []
        
        for element in self {
            if condition(element) {
                matches.append(element)
            } else {
                nonMatches.append(element)
            }
        }
        
        return (matches, nonMatches)
    }
}
