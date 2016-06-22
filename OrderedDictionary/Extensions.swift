//
//  Extensions.swift
//  OrderedDictionary
//
//  Created by Dan Zimmerman on 6/21/16.
//  Copyright © 2016 Dan Zimmerman. All rights reserved.
//

// We can check directly if a value exists if `Value: Equatable`
public extension OrderedDictionary where Value: Equatable {
    // Convenience method to check if the `OrderedDictionary` contains `value`.
    func containsValue(_ value: Value) -> Bool {
        return containsValue { $0 == value }
    }
}

// If we're using Keys that have an implicit order we can use that implicit order.
public extension OrderedDictionary where Key: Comparable {
    // Convenience initializer that uses `Key`'s `<` to order its elements.
    init(dictionary: [Key: Value]) {
        self.init(dictionary: dictionary) { $0 < $1 }
    }
}
