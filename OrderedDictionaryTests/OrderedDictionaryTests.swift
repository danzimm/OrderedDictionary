//
//  OrderedDictionaryTests.swift
//  OrderedDictionaryTests
//
//  Created by Dan Zimmerman on 6/21/16.
//  Copyright © 2016 Dan Zimmerman. All rights reserved.
//

import XCTest
@testable import OrderedDictionary

enum SampleKey: Hashable {
    case Whoa
    case Woah
    case Woa
    var hashValue: Int {
        switch self {
        case .Whoa:
            return 0
        case .Woah:
            return 1
        case .Woa:
            return 2
        }
    }
}

enum SampleComparableKeys: Hashable {
    case Im
    case A
    case Little
    case Teapot
    
    var hashValue: Int {
        switch self {
        case .Im:
            return 0
        case .A:
            return 1
        case .Little:
            return 2
        case .Teapot:
            return 3
        }
    }
}

extension SampleComparableKeys: Comparable {}

func == (left: SampleComparableKeys, right: SampleComparableKeys) -> Bool {
    switch (left, right) {
    case (.Im, .Im), (.A, .A), (.Little, .Little), (.Teapot, .Teapot):
        return true
    default:
        return false
    }
}

func < (left: SampleComparableKeys, right: SampleComparableKeys) -> Bool {
    switch (left, right) {
    case (.Im, let x) where x != .Im:
        return true
    case (.A, let x) where x != .Im && x != .A:
        return true
    case (.Little, .Teapot):
        return true
    default:
        return false
    }
}

class OrderedDictionaryTestsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithExplicitKeys() {
        let keys = ["rick", "house", "bender"]
        let dict = [
            "house": "humanity is overrated",
            "bender": "i dont have emotions and sometimes that makes me feel sad",
            "rick": "thats planning for failure, morty. even dumber than regular planning"
        ]
        guard let orderedDict = try? OrderedDictionary(dictionary: dict, keys: keys) else {
            XCTFail("Expect a dictionary to be properly initialized when given a dictionary and an array of keys matching the keys in the dictionary.")
            return
        }
        for (index, key) in keys.enumerated() {
            XCTAssert(orderedDict[index] == orderedDict[key],
                      "Settng the order of the dictionary via an array of keys should work.")
            XCTAssert(orderedDict[key] == dict[key],
                      "The OrderedDictionary should return the proper value associated with a given key when initialized with a dictionary and an explicit array of keys.")
        }
        for (index, (key, _)) in orderedDict.enumerated() {
            XCTAssert(index == keys.index(of: key),
                      "Enumerating a dictionary should happen in the correct order.")
        }
    }
    
    func testInitWithExplicitOrder() {
        let keys: [SampleKey] = [.Whoa, .Woah, .Woa]
        let dict = [
            SampleKey.Woah: "Woah",
            SampleKey.Woa: "Woa",
            SampleKey.Whoa: "Whoa"
        ]
        let orderedDict = OrderedDictionary(dictionary: dict) { return $0.hashValue <= $1.hashValue }
        for (index, key) in keys.enumerated() {
            XCTAssert(orderedDict[index] == orderedDict[key],
                      "Settng the order of the dictionary via a sorting algorithm should work.")
            XCTAssert(orderedDict[key] == dict[key],
                      "The OrderedDictionary should return the proper value associated with a given key when initialized with a dictionary and an explicit order.")
        }
        for (index, (key, _)) in orderedDict.enumerated() {
            XCTAssert(index == keys.index(of: key),
                      "Enumerating a dictionary should happen in the correct order.")
        }
    }
    
    func testInitWithImplicitOrder() {
        let keys: [SampleComparableKeys] = [.Im, .A, .Little, .Teapot]
        let dict: [SampleComparableKeys: String] = [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Im: "Who am I, really?",
            .Little: "Stuart",
            ]
        let orderedDict = OrderedDictionary(dictionary: dict)
        for (index, key) in keys.enumerated() {
            XCTAssert(orderedDict[index] == orderedDict[key],
                      "Settng the order of the dictionary using the comparison operator on the keys should work.")
            XCTAssert(orderedDict[key] == dict[key],
                      "The OrderedDictionary should return the proper value associated with a given key when initialized with a dictionary and an implicit order.")
        }
        for (index, (key, _)) in orderedDict.enumerated() {
            XCTAssert(index == keys.index(of: key),
                      "Enumerating a dictionary should happen in the correct order.")
        }
    }
    
    func testInitWithBadKeys() {
        let keys = ["hello", "world", "how", "are", "you"]
        let otherKeys = ["hello"]
        let weirdKeys = ["goodbye", "moon"]
        let duplicateKeys = ["hello", "hello", "world"]
        let dict = [
            "hello": "how are you?",
            "world": "little blue marble"
        ]
        XCTAssert((try? OrderedDictionary(dictionary: dict, keys: duplicateKeys)) == nil,
                  "Initializing an OrderedDictionary with an array of keys with duplicates shouldn't work.")
        XCTAssert((try? OrderedDictionary(dictionary: dict, keys: keys)) == nil,
                  "Initializing an OrderedDictionary with an array of keys that contains more elements than the keys in the dictionary should throw an error.")
        XCTAssert((try? OrderedDictionary(dictionary: dict, keys: otherKeys)) == nil,
                  "Initializing an OrderedDictionary with a dictionary that contains keys not present in the keys array should thow an error.")
        XCTAssert((try? OrderedDictionary(dictionary: dict, keys: weirdKeys)) == nil,
                  "Initializing an OrderedDictionary with a dictionary that contains no keys in common with the keys array should throw an error.")
    }
    
    func testInitWithSequence() {
        let pairs = [
            ("hello", "world"),
            ("how", "are"),
            ("you", "doing")
        ]
        guard let orderedDict = try? OrderedDictionary(sequence: pairs) else {
            XCTFail("Initializing an ordered dictionary with a valid sequence should return a valid value.")
            return
        }
        for (index, (key, value)) in pairs.enumerated() {
            XCTAssert(orderedDict[index] == value,
                      "Initializing an OrderedDictionary with a sequence should return a properly ordered dictionary according to the order of that sequence")
            XCTAssert(orderedDict[key] == value,
                      "The OrderedDictionary should return the proper value behind a given key when initialized with a sequence")
        }
    }
    
    func testInitWithBadSequence() {
        let pairs = [
            ("hello", "world"),
            ("hello", "mars"),
            ]
        XCTAssert((try? OrderedDictionary(sequence: pairs)) == nil,
                  "Initializing an OrderedDictionary with a sequence with duplicate keys should throw an error")
    }
    
    func testAppend() {
        let dict: [SampleComparableKeys: String] = [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ]
        var orderedDict = OrderedDictionary(dictionary: dict)
        XCTAssert((try? orderedDict.append(key: .Im, value: "Who am I really though?")) != nil,
                  "Appending a key/value pair that doesn't already exist should work")
        XCTAssert(orderedDict[orderedDict.count-1] == (.Im, "Who am I really though?"),
                  "After appending the last key/value should be the key/value appended.")
        XCTAssert(orderedDict[.Im] == "Who am I really though?",
                  "After appending a key/value pair the value associated with key should be proper.")
    }
    
    func testAppendAlreadyExists() {
        let dict: [SampleComparableKeys: String] = [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ]
        var orderedDict = OrderedDictionary(dictionary: dict)
        XCTAssert((try? orderedDict.append(key: .Teapot, value: "Whoops")) == nil,
                  "Appending a key/value pair where the key already exists should throw an error")
    }
    
    func testInsert() {
        let dict: [SampleComparableKeys: String] = [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ]
        var orderedDict = OrderedDictionary(dictionary: dict)
        XCTAssert((try? orderedDict.insert(key: .Im, value: "Who am I really though?", atIndex: 1)) != nil,
                  "Inserting a valid key/value pair should not error.")
        XCTAssert(orderedDict[.Im] == "Who am I really though?",
                  "After inserting a key/value pair getting the value behind the key inserted should be proper.")
        XCTAssert(orderedDict[1] == (.Im, "Who am I really though?"),
                  "Inserting a key/value pair at a certain index should make the dictionary return the same pair for that index.")
    }
    
    func testInsertAlreadyExists() {
        let dict: [SampleComparableKeys: String] = [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ]
        var orderedDict = OrderedDictionary(dictionary: dict)
        XCTAssert((try? orderedDict.insert(key: .Teapot, value: "Whoops", atIndex: 1)) == nil,
                  "Inserting a key/value pair when the key already exists should throw an error.")
    }
    
    func testContains() {
        let orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        XCTAssert(orderedDict.containsKey(.Teapot))
        XCTAssert(orderedDict.containsValue("Stuart"))
    }
    
    func testSetValueAtIndex() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        let originalPair: (SampleComparableKeys, String) = orderedDict[0]
        orderedDict[0] = "EEEEEE"
        XCTAssert(orderedDict[0] == "EEEEEE",
                  "Setting a value at an index should persist")
        XCTAssert(orderedDict[0].0 == originalPair.0,
                  "Setting a value at an index should keep the same key at that index")
    }
    
    func testSetKeyValueAtIndex() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        let originalPair: (SampleComparableKeys, String) = orderedDict[0]
        orderedDict[0] = (.Im, "Who am I really?")
        XCTAssert(orderedDict[0] == (.Im, "Who am I really?"),
                  "Setting a key/value pair at an index should persist")
        XCTAssert(!orderedDict.containsKey(originalPair.0),
                  "Setting a key/value pair at an index should remove the old key/value pair at that index")
    }
    
    func testSetValueForKey() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        orderedDict[.Im] = "Who am I really?"
        XCTAssert(orderedDict[orderedDict.count - 1] == (.Im, "Who am I really?"),
                  "Setting a value for a key when the key doesnt already exist appends the pair to the end of the OrderedDictionary.")
    }
    
    func testSetNilForKey() throws {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        let otherDict = orderedDict
        orderedDict[.Im] = nil
        XCTAssert(orderedDict == otherDict,
                  "Setting a nil value for a new key should do nothing")
        orderedDict[.Teapot] = nil
        XCTAssert(orderedDict != otherDict,
                  "Setting a nil value for an existing key should change the dictionary")
        XCTAssert(!orderedDict.containsKey(.Teapot),
                  "Setting a nil value for an existing key should delete that key")
        try orderedDict.sanityCheck()
    }
    
    func testSetValueForKeyAlreadyExists() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        orderedDict[.A] = "Ayyyyyyyyyyyyy"
        XCTAssert(orderedDict[.A] == "Ayyyyyyyyyyyyy",
                  "Setting the value for a key that already exists should overwrite the value at that key")
    }
    
    func testGetValueForIndex() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        XCTAssert(orderedDict[0] == "Not the, but a",
                  "Getting a value pair at an index should return the proper value")
    }
    
    func testGetKeyValueForIndex() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        XCTAssert(orderedDict[0] == (.A, "Not the, but a"),
                  "Getting a key/value pair at an index should return the proper key/value")
    }
    
    func testGetValueForKey() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        XCTAssert(orderedDict[.Little] == "Stuart",
                  "Getting a value by the key associated with it should return the proper value.")
    }
    
    func testGetValueForKeyDoesntExist() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        XCTAssert(orderedDict[.Im] == nil,
                  "Getting the value of a key that doesn't exist should return nil")
    }
    
    func testRemoveAll() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        orderedDict.removeAll()
        XCTAssert(orderedDict.count == 0,
                  "Removing all the pairs of an OrderedDictionary should work.")
        XCTAssert(orderedDict[.A] == nil,
                  "Removing all the pairs of an OrderedDictionary should not leave any keys behind.")
    }
    
    func testRemoveForKey() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        orderedDict.removeValue(forKey: .A)
        XCTAssert(orderedDict[.A] == nil,
                  "Removing all the pairs of an OrderedDictionary should not leave any keys behind.")
    }
    
    func testRemoveAtIndex() {
        var orderedDict = OrderedDictionary<SampleComparableKeys, String>(dictionary: [
            .Teapot: "Would anyone like some sugar or honey?",
            .A: "Not the, but a",
            .Little: "Stuart",
            ])
        orderedDict.removeValue(at: 0)
        XCTAssert(orderedDict[.A] == nil,
                  "Removing all the pairs of an OrderedDictionary should not leave any keys behind.")
    }
}
