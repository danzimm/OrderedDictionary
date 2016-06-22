# OrderedDictionary

This is a data structure made out of an array and a dictionary. Its purpose is to supply a method to order key/value pairs while retaining the quick lookup time of a value from a key. The structure ensures the internal keys and dictionary values are always in sync.

# Tutorial
```swift
let orderedDict = OrderedDictionary(dictionary: [
    "hello": "world",
    "how": "about",
    "that": "order",
], keys: ["that", "how", "hello"])
for (key, value) in orderedDict {
    print("\(key): \(value)")
}
// Output:
// that: order
// how: about
// hello: world
```

# More Info

`OrderedDictionary` abides by the Collection proptocol so you can use all the fun operators that you're used to using. Look to the comments for more information about how to use the structure.
