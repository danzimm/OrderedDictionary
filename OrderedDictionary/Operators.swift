//
//  Operators.swift
//  OrderedDictionary
//
//  Created by Dan Zimmerman on 6/21/16.
//  Copyright © 2016 Dan Zimmerman. All rights reserved.
//

// Unfortunately we can't make OrderedDictionary abide by `Equatable` because that relies on the parameters `Key`, `Value` abiding by `Equatable`. This checks that the dictionaries have the same number of key/value pairs and that all the pairs are equal.
public func == <Key: Hashable, Value: Equatable where Key: Equatable>(
    left: OrderedDictionary<Key, Value>, right: OrderedDictionary<Key, Value>) -> Bool {
    let allKeysCount = Set(left.keys).union(right.keys).count
    if allKeysCount != left.count || allKeysCount != right.count {
        return false
    }
    for (index, pair) in left.enumerated() {
        let rightPair: (Key, Value) = right[index]
        if rightPair != pair {
            return false
        }
    }
    return true
}

// Identical to `!(left == right)` where `left == right` is defined above.
public func != <Key: Hashable, Value: Equatable where Key: Equatable>(
    left: OrderedDictionary<Key, Value>, right: OrderedDictionary<Key, Value>) -> Bool {
    return !(left == right)
}
