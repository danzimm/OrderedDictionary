//
//  OrderedDictionary.swift
//  OrderedDictionary
//
//  Created by Dan Zimmerman on 6/19/16.
//  Copyright © 2016 Dan Zimmerman. All rights reserved.
//

// A structure containing an array of (Key, Value) pairs with the performance benefit of being
// able to look up a value by its corresponding key as well.
public struct OrderedDictionary<Key: Hashable, Value>: MutableCollection, CustomStringConvertible {
    // Private variables backing this structure.
    private(set) var dictionary: [Key: Value]
    private(set) var keys: Array<Key>
    
    // Returns a pretty string representing this data stucture e.g.
    // {
    //   (0) -> hello: world
    //   (1) -> goodbye: mars
    // }
    // Complexity: O(`count`).
    public var description: String {
        return keys.enumerated().reduce("OrderedDictionary<\(Key.self), \(Value.self)>{\n") { (accu, tuple) -> String in
            return accu + "\t(\(tuple.0)) -> \(tuple.1): \(self[tuple.1]!)\n"
        } + "}"
    }
    
    // The type element for the Collection. We follow the standard set by Dictionary and use (Key, Value).
    // We need to explicitly set this because we have multiple subscripts defined and the compiler doesn't
    // know which to use otherwise.
    public typealias _Element = (Key, Value)
    
    // The initial index of this collection. Always a constant `0`, although as you know quantum physics
    // says anything can happen and thus it may be 42.
    // Complexity: O(`1`).
    public var startIndex: Int { return 0 }
    // The index past the last element of this collection. Aka `count - 1`. We define `endIndex` explicitly
    // and let the `Collection` protocol define `count`.
    // Complexity: O(`1`).
    public var endIndex: Int { return keys.count }
    
    // Initialize the ODict with a dictionary of key/value pairs and an explicit order.
    // Complexity: The same as `Sequence.sorted(:)`. Probably O(nlog(n)).
    public init(dictionary: [Key: Value], order: (Key, Key) -> Bool) {
        self.dictionary = dictionary
        self.keys = dictionary.keys.sorted(isOrderedBefore: order)
    }
    
    // Initialize the ODict with a dictionary of key/value pairs and an array of keys to dictate the order.
    // This may throw a `OrderedDictionaryInitializationError.KeysMismatch` if the keys in the dictionary
    // don't match with the `keys` supplied.
    // Complexity: O(`dictionary.count + keys.count`).
    public init(dictionary: [Key: Value], keys: [Key]) throws {
        self.dictionary = dictionary
        self.keys = keys
        try self.sanityCheck()
    }
    
    // Initialize the ODict with a sequence of (Key, Value) pairs. The order is taken from the order that
    // elements are taken from the sequence.
    // Complexity: O(`sequence.count`).
    public init<T: Sequence where T.Iterator.Element == (Key, Value)>(sequence: T) throws {
        self.dictionary = [:]
        self.keys = []
        
        for (key, value) in sequence {
            guard self.dictionary[key] == nil else {
                throw OrderedDictionaryInitializationError.DuplicateKey
            }
            self.dictionary[key] = value
            self.keys.append(key)
        }
    }
    
    // Append a key/value pair to the end of the odict. 
    // May throw `OrderedDictionaryMutationError.Append(key)` if the key already exists.
    // Complexity: O(`1`).
    public mutating func append(key: Key, value: Value) throws {
        if dictionary[key] != nil {
            throw OrderedDictionaryMutationError.Append(key)
        }
        self[key] = value
    }
    
    // Insert a key/value pair at a specific index in the odict.
    // May throw `OrderedDictionaryMutationError.Insert(key)` if the key already exists.
    // Complexity: O(`count`).
    public mutating func insert(key: Key, value: Value, atIndex index: Int) throws {
        if dictionary[key] != nil {
            throw OrderedDictionaryMutationError.Insert(key)
        }
        keys.insert(key, at: index)
        dictionary[key] = value
    }
    
    // Removes all the entries in the odict optionally keeping capacity. See `Dictionary.removeAll` for more
    // information.
    // Complexity: O(`count`).
    public mutating func removeAll(keepingCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepingCapacity)
        keys.removeAll(keepingCapacity: keepingCapacity)
    }
    
    // Remove a key/value pair. Removes the entry at the corresponding index as well. Returns the key/value
    // pair if the `key` is found.
    // Complexity: O(`count`).
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> (Key, Value)? {
        guard let index = keys.index(of: key) else {
            return nil
        }
        return removeValue(at: index)
    }
    
    // Remove a key/value pair at a given `index`. Returns the key/value pair at `index`. 
    // Precondition: `index` >= 0 && `index` < `count`
    // Complexity: O(`count`).
    @discardableResult
    public mutating func removeValue(at index: Int) -> (Key, Value) {
        let key = keys.remove(at: index)
        guard let value = dictionary.removeValue(forKey: key) else {
            fatalError("OrderedDictionary internal mimatch: found a key in the order key array not in the internal dictionary storage")
        }
        return (key, value)
    }
    
    // Convenience method to check if a certain value exists in the odict.
    // Complexity: Same as complexity of `contains` as defined on `Sequence`. My guess is O(`count`).
    public func containsValue(_ predicate: @noescape (Value) -> Bool) -> Bool {
        return contains { predicate($0.1) }
    }
    
    // Convenience method to check if a key following some predicate exists in the odict. 
    // Complexity: Same as complexity of `contains` as defined on `Sequence`. My guess is O(`count`).
    public func containsKey(_ predicate: @noescape (Key) -> Bool) -> Bool {
        return contains { predicate($0.0) }
    }
    
    // Convenience method to check if a `key` exists in the odict. 
    // Complexity: O(1).
    public func containsKey(_ key: Key) -> Bool {
        return dictionary[key] != nil
    }
    
    // Get the value at a certain index. Setting a value at a given index keeps the same key at that index.
    // Complexity: O(`1`).
    public subscript(index: Int) -> Value {
        get {
            guard let value = dictionary[keys[index]] else {
                fatalError("OrderedDictionary internal mimatch: found a key in the order key array not in the internal dictionary storage")
            }
            return value
        }
        set {
            dictionary[keys[index]] = newValue
        }
    }
    
    // Get the key/value pair at a certain index. This is the subscript backing the Collection.
    // Setting a key/value pair replaces the key/value pair at `index` with the one supplied. If the `key`
    // supplied already exists then it and its corresponding value is first removed. Finally the key/value
    // pair is set at `index`.
    // Complexity:
    //  get: O(`1`)
    //  set: O(`count`)
    public subscript(index: Int) -> (Key, Value) {
        get {
            let key = keys[index]
            guard let value = dictionary[key] else {
                fatalError("OrderedDictionary internal mimatch: found a key in the order key array not in the internal dictionary storage")
            }
            return (key, value)
        }
        set {
            let key = newValue.0
            let value = newValue.1
            
            // Remove the key/value pair at `index`
            let oldKey = keys.remove(at: index)
            dictionary.removeValue(forKey: oldKey)
            
            // If the key already exists then move it by removing the key.
            if let oldIndex = keys.index(of: key) {
                keys.remove(at: oldIndex)
            }
            // Finally insert the key/value pair in the backing storage and the key at the proper index.
            dictionary[key] = value
            keys[index] = key
        }
    }
    
    // Returns the value behind `key`.
    // Setting a new key/value pair will append the pair to the end of the odict if the key doesn't exist,
    // otherwise it keeps the key/value pair at the same index and just updates the value at `key`.
    // If `value` == nil then we remove the `key/value` pair entirely.
    // Complexity:
    //  get: O(`1`)
    //  set: O(`count`) if `value == nil` else O(`1`)
    public subscript(key: Key) -> Value? {
        get {
            return dictionary[key]
        }
        set {
            if let value = newValue {
                if dictionary[key] == nil {
                    keys.append(key)
                }
                dictionary[key] = value
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    // Method backing Collection to create the default Iterator. Simply returns `index + 1` with a
    // precondition of `index >= endIndex`.
    // Complexity: O(`1`).
    public func index(after index: Int) -> Int {
        precondition(index < endIndex, "Cannot advance beyond last index")
        return index + 1
    }
    
    // Internal function for testing to ensure the keys/dictionary are in sync.
    // Throws `OrderedDictionaryInitializationError.KeysMismatch` if out of sync.
    // Complexity: O(`dictionary.count + keys.count`).
    internal func sanityCheck() throws {
        let allKeysCount = Set(dictionary.keys).union(keys).count
        if allKeysCount != dictionary.count || allKeysCount != keys.count {
            throw OrderedDictionaryInitializationError.KeysMismatch
        }
    }
}
