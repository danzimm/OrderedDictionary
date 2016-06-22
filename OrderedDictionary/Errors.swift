//
//  Errors.swift
//  OrderedDictionary
//
//  Created by Dan Zimmerman on 6/21/16.
//  Copyright © 2016 Dan Zimmerman. All rights reserved.
//

// This file contains the errors associated with an OrderedDictionary. Unfortunately these cannot be nested inside of `OrderedDictionary` itself because you can't nest types inside of generic types (yet).

// This is thrown when inserting/appending a key/value pair when the key already exists.
public enum OrderedDictionaryMutationError<Key>: ErrorProtocol, CustomStringConvertible {
    case Append(Key)
    case Insert(Key)
    
    public var description: String {
        switch self {
        case let .Append(key):
            return "\(key) already exists in dictionary, unable to append it."
        case let .Insert(key):
            return "\(key) already exists in dictionary, unable to insert it."
        }
    }
}

// This is thrown when you try to initialize the `OrderedDictionary` with bad data.
public enum OrderedDictionaryInitializationError: ErrorProtocol, CustomStringConvertible {
    case KeysMismatch
    case DuplicateKey
    
    public var description: String {
        switch self {
        case .KeysMismatch:
            return "Initializing an OrderedDictionary with an explicit array of keys must match the keys in the dictionary supplied"
        case .DuplicateKey:
            return "Initializing an OrderedDictionary with a sequence of (Key, Value) requires keys to be unique."
        }
    }
}
