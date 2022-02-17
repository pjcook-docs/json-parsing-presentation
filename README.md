# Learning about JSON parsing on iOS

## What are the different options

There are multiple ways to do JSON parsing in Swift:
• Codable
• JSON Serialization
• Direct string manipulation

Whilst I have listed 3 options above, I definitely wouldn't suggestion using the last option. Apple have provided 2 very good and capable solutions for encoding and decoding JSON, Codable and JSON Serialization.

Codable is Apple's newer solution for working with JSON and provides a simple light touch approach to dealing with JSON formatted data. It is also highly flexible allowing you to map custom keys to data models with different property names, as well as different structures, however if the JSON structure diverges from your preferred model structure too much, you may need to firstly parse and then translate the JSON data.

Codable allows you to easily encode and decode simple JSON data structures with very little code, although can get more complicated if the JSON structure and property names do not match your models.

JSON Serialization is a much older solution that Apple provided way back towards the start of iOS development. JSON Serialization, in essence, boils down JSON into Arrays [Any] and Dictionaries [String:Any].

With JSON Serialization, you can parse much more complex JSON structures that are impossible to process with Codable.

It's the most flexible solution to JSON parsing, but requires you to manually code all of the validation and translation for the entire JSON document. I will show you a fairly simple standardised pattern that you can use to follow to make this slightly easier, but it does not reduce the amount of boiler plate code that you have to write yourself. There were some shortcuts with Objective-C type inference, but these options are not available in Swift, so I won't go into those details here.

## Simple example

### Codable

Starting with the simplest possible Codable solution with *Info*. There are tests in the *SimpleCodableTests* class that show how easy it is to encode and decode this type of object using Codable.

```swift
public struct Info: Codable {
    public let name: String
}

func testJSON_toObject() throws {
    guard let jsonData = "{\"name\":\"Roger\"}".data(using: .utf8) else {
        throw InvalidJson(json: "{\"name\":\"Roger\"}")
    }

    let info = try JSONDecoder().decode(Info.self, from: jsonData)
    XCTAssertEqual("Roger", info.name)
}
```

Adding in a few extensions allows us to simplify the above code to:

```swift
func testJSON_toObject() throws {
    let jsonData = try "{\"name\":\"Roger\"}".toJsonData()
    let info = try Info.decode(jsonData)
    XCTAssertEqual("Roger", info.name)
}
```

Here are the extensions:

```swift
extension String {
    func toJsonData() throws -> Data {
        guard let jsonData = self.data(using: .utf8) else {
            throw InvalidJson(json: self)
        }
        return jsonData
    }
}

extension Decodable {
    static func decode(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
```

### JSON Serializable

Compared to the 2 line struct for the simple Codable solution, the Serialization version requires more code. For simplicity I am going to reuse the codable class, and simply extend it with a couple standard functions that I like to use with JSON Serialization.

```swift
extension Info {
    public init(_ dict: [String: Any]) throws {
        self.name = try dict.value("name")
    }
    
    public var dictionary: [String: Any] {
        ["name": name]
    }
}
```

To be fair that wasn't too much additional code, but again I cheated slightly with some useful extensions, and the *dictionary* property is only required if you want to convert the data model back into a dictionary. I added it because I'm using it in the unit tests.

```swift
extension Dictionary where Key == String, Value == Any {
    func value(_ forKey: String) throws -> String {
        guard let value = self[forKey] as? String else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
}
```

If you look in the *JSONSerializable+Dictionary* file you will see matching functions for other data types.

In the Codable solution there were pretty much only 3 tests that I thought to write, but for the Serializable code there are many more.

```swift
class SimpleSerializationTests: XCTestCase {
    func testDictionary_toObject() throws {
        let dict = ["name": "Roger"]
        let info = try Info(dict)
        XCTAssertEqual(info.name, "Roger")
    }
    
    func testDictionaryToObject_throws() throws {
        let dict = ["name": 123]
        XCTAssertThrowsError(try Info(dict), "Failed") { error in
            XCTAssertTrue(error is InvalidProperty)
        }
    }

    func testDictionary_toJSON() throws {
        let expected = "{\"name\":\"Roger\"}"
        let dict = ["name": "Roger"]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
    
    func testDictionary_toObject_toJSON() throws {
        let expected = "{\"name\":\"Roger\"}"
        let dict = ["name": "Roger"]
        let info = try Info(dict)
        let jsonData = try JSONSerialization.data(withJSONObject: info.dictionary, options: .fragmentsAllowed)
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
    
    func testJSONToObject() throws {
        let jsonData = try "{\"name\":\"Roger\"}".toJsonData()
        let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String:Any]
        XCTAssertNotNil(dict)
        guard let dict = dict else { return }
        let info = try Info(dict)
        XCTAssertEqual("Roger", info.name)
    }
    
    func testObjectToDictionary() throws {
        let info = Info(name: "Roger")
        let dict = info.dictionary
        XCTAssertEqual("Roger", dict["name"] as? String)
    }
    
    func testObjectToJSON() throws {
        let expected = "{\"name\":\"Roger\"}"
        let info = Info(name: "Roger")
        let jsonData = try JSONSerialization.data(withJSONObject: info.dictionary, options: .fragmentsAllowed)
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
}
```

## When the JSON keys don't match your model names

When the field names do not match your model names, it's easily fixed.

### Codable 

```swift
public struct DetailedInfo: Codable, Equatable {
    public let name: String
    public let age: Int
    public let pet: String?
    public let color: String?
    
    public enum CodingKeys: String, CodingKey {
        case name
        case age
        case pet = "favourite_pet"
        case color = "favourite_color"
    }
}
```

You cannot guarantee the data structure produced when encoding JSON. This can make unit testing challenging, you can't just cast your encoded JSON to a String and compare it against an expected example.

```swift
class DetailedCodableTests: XCTestCase {
    func testJSON_toObject() throws {
        let jsonData = try "{\"name\":\"Roger\",\"age\":35}".toJsonData()
        let info = try JSONDecoder().decode(DetailedInfo.self, from: jsonData)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertNil(info.pet)
        XCTAssertNil(info.color)
    }
    
    func testJSON_toFullObject() throws {
        let jsonData = try "{\"name\":\"Roger\",\"age\":35,\"favourite_pet\":\"Garfield\",\"favourite_color\":\"Red\"}".toJsonData()
        let info = try JSONDecoder().decode(DetailedInfo.self, from: jsonData)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertEqual("Garfield", info.pet)
        XCTAssertEqual("Red", info.color)
    }
    
    func testObject_toJSON() throws {
        let expected = "{\"name\":\"Roger\",\"age\":35}"
        let info = DetailedInfo(name: "Roger", age: 35, pet: nil, color: nil)
        let jsonData = try JSONEncoder().encode(info)

        /* This won't work because the order of the fields that get output is random */
//        let output = String(data: jsonData, encoding: .utf8)
//        XCTAssertEqual(expected, output)
        
        let expectedJSONData = try expected.toJsonData()
        let info1 = try JSONDecoder().decode(DetailedInfo.self, from: jsonData)
        let info2 = try JSONDecoder().decode(DetailedInfo.self, from: expectedJSONData)
        XCTAssertEqual(info1.name, info2.name)
        XCTAssertEqual(info1.age, info2.age)
        XCTAssertEqual(info1.pet, info2.pet)
        XCTAssertEqual(info1.color, info2.color)
    }
    
    func testObject_toFullJSON() throws {
        let expected = "{\"name\":\"Roger\",\"age\":35,\"favourite_pet\":\"Garfield\",\"favourite_color\":\"Red\"}"
        let info = DetailedInfo(name: "Roger", age: 35, pet: "Garfield", color: "Red")
        let jsonData = try JSONEncoder().encode(info)
        let expectedJSONData = try expected.toJsonData()
        let info1 = try JSONDecoder().decode(DetailedInfo.self, from: jsonData)
        let info2 = try JSONDecoder().decode(DetailedInfo.self, from: expectedJSONData)
        XCTAssertEqual(info1.name, info2.name)
        XCTAssertEqual(info1.age, info2.age)
        XCTAssertEqual(info1.pet, info2.pet)
        XCTAssertEqual(info1.color, info2.color)
    }
}
```

### JSON Serializable

The serializable init function following the pattern *init with dictionary* is:

```swift
extension DetailedInfo {
    public init(_ dict: [String: Any]) throws {
        self.name = try dict.value("name")
        self.age = try dict.value("age")
        self.pet = dict["favourite_pet"] as? String
        self.color = dict["favourite_color"] as? String
    }
    
    public var dictionary: [String: Any] {
        [
            "name": name,
            "age": age,
            "favourite_pet": pet as Any,
            "favourite_color": color as Any
        ]
    }
}
```

The tests look almost identical to before:

```swift
class DetailedSerializableTests: XCTestCase {
    let simpleJson = "{\"name\":\"Roger\",\"age\":35}"
    let detailedJson = "{\"name\":\"Roger\",\"age\":35,\"favourite_pet\":\"Garfield\",\"favourite_color\":\"Red\"}"
    
    func testJSON_toObject() throws {
        let dict = try simpleJson.toJsonData().jsonToDictionary()
        let info = try DetailedInfo(dict)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertNil(info.pet)
        XCTAssertNil(info.color)
    }
    
    func testJSON_toFullObject() throws {
        let dict = try detailedJson.toJsonData().jsonToDictionary()
        let info = try DetailedInfo(dict)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertEqual("Garfield", info.pet)
        XCTAssertEqual("Red", info.color)
    }
    
    func testObject_toJSON() throws {
        let info = DetailedInfo(name: "Roger", age: 35, pet: nil, color: nil)
        let jsonData = try info.dictionary.toJsonData()
        let expectedJSONData = try simpleJson.toJsonData()
        let info1 = try DetailedInfo.decode(jsonData)
        let info2 = try DetailedInfo.decode(expectedJSONData)
        XCTAssertEqual(info1.name, info2.name)
        XCTAssertEqual(info1.age, info2.age)
        XCTAssertEqual(info1.pet, info2.pet)
        XCTAssertEqual(info1.color, info2.color)
    }
    
    func testObject_toFullJSON() throws {
        let info = DetailedInfo(name: "Roger", age: 35, pet: "Garfield", color: "Red")
        let jsonData = try info.dictionary.toJsonData()
        let expectedJSONData = try detailedJson.toJsonData()
        let info1 = try DetailedInfo.decode(jsonData)
        let info2 = try DetailedInfo.decode(expectedJSONData)
        XCTAssertEqual(info1.name, info2.name)
        XCTAssertEqual(info1.age, info2.age)
        XCTAssertEqual(info1.pet, info2.pet)
        XCTAssertEqual(info1.color, info2.color)
    }
}
```

You will be looking at the above JSONSerializable example and asking yourself why you would ever want to use this over the Codable solution, and I don't blame you. It looks like hard work, there are more test edge cases and it's way more effort. Well if you can nicely align your API JSON and App data models then feel free to stick with Codable. And if your API JSON has a nice single definition then, yes, stick with Codable. If your API JSON goes off piste and into some more advanced directions then you might have no choice but to look at JSONSerializable.

## Complex Example 1

Let's say that we would like to flatten the following JSON:

```json
{
   "name": "Tim Apple",
   "address": {
      "address1": "1 Infinity Loop",
      "address2": "San Francisco",
      "address3": "California",
      "zip": 12345
   },
   "personalDetails": {
      "favourite_color": "White",
      "favourite_fruit": "Apple"
   }
}
```

### Codable

To do that with Codable, the easiest solution would be to build a set of model classes that exactly mapped to the above data structure, decode that, and then translate that into the model structure that you actually wanted.

```swift
enum API {
    struct Person: Codable {
        let name: String
        let address: Address
        let personalDetails: PersonalDetails
    }
    
    struct Address: Codable {
        let address1: String
        let address2: String?
        let address3: String?
        let zip: Int
    }
    
    struct PersonalDetails: Codable {
        let favourite_color: String?
        let favourite_fruit: String?
    }
}

struct Person {
    let name: String
    let address1: String
    let address2: String?
    let address3: String?
    let zip: Int
    let color: String?
    let fruit: String?
    
    init(_ api: API.Person) {
        self.name = api.name
        self.address1 = api.address.address1
        self.address2 = api.address.address2
        self.address3 = api.address.address3
        self.zip = api.address.zip
        self.color = api.personalDetails.favourite_color
        self.fruit = api.personalDetails.favourite_fruit
    }
}
```

The above is a good solution, and incorporates separation of concerns. The only real down side is that you had to make 2 different data structures to parse the API data.

### JSON Serializable

Using serialization you don't need multiple models, you can do all the parsing in a single function:

```swift
extension Person {
    init(_ dict: [String: Any]) throws {
        self.name = try dict.value("name")
        
        let address: [String: Any] = try dict.value("address")
        self.address1 = try address.value("address1")
        self.address2 = address["address2"] as? String
        self.address3 = address["address3"] as? String
        self.zip = try address.value("zip")
        
        let personalDetails: [String: Any] = try dict.value("personalDetails")
        self.color = personalDetails["favourite_color"] as? String
        self.fruit = personalDetails["favourite_fruit"] as? String
    }
}
```

## Complex Example 2

Say you had a product, and that product had a Price object, but the structure of the price could vary between a simple single value and a price range.

### Codable

```swift
typealias ProductSize = String
typealias ProductColor = String

struct ComplexProduct: Codable {
    let id: String
    let title: String
    let productDescription: String
    let price: Price
    let size: ProductSize?
    let color: ProductColor?
    
    public enum CodingKeys: String, CodingKey {
        case id = "productId"
        case title
        case productDescription = "description"
        case price
        case size
        case color
    }
}

struct Price: Codable {
    let was: PriceValue?
    let then1: PriceValue?
    let then2: PriceValue?
    let now: PriceValue?
    let uom: String?
    let currency: String?
}

enum PriceValue: Equatable, Codable {
    case single(String?)
    case range(PriceRange?)
    
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = .single(nil)
            return
        }
        do {
            let value = try container.decode(String.self)
            self = .single(value)
        } catch {
            let value = try? container.decode(PriceRange.self)
            self = .range(value)
        }
    }
}

struct PriceRange: Codable, Equatable {
    let from: String?
    let to: String?

    enum CodingKeys: String, CodingKey {
        case from = "from"
        case to = "to"
    }
}
```

### JSON Serializable

```swift
extension ComplexProduct {
    init(_ dict: [String: Any]) throws {
        self.id = try dict.value("productId")
        self.title = try dict.value("title")
        self.productDescription = try dict.value("description")
        self.price = try Price(dict.value("price"))
        self.size = dict["size"] as? ProductSize
        self.color = dict["color"] as? ProductColor
    }
}

extension Price {
    init(_ dict: [String: Any]) {
        self.was = PriceValue(dict["was"])
        self.then1 = PriceValue(dict["then1"])
        self.then2 = PriceValue(dict["then2"])
        self.now = PriceValue(dict["now"])
        self.uom = dict["uom"] as? String
        self.currency = dict["currency"] as? String
    }
}

extension PriceValue {
    init?(_ value: Any?) {
        guard let value = value else { return nil }
        if let value = value as? String {
            self = .single(value)
        } else if let value = value as? [String: Any] {
            self = .range(PriceRange(value))
        } else {
            return nil
        }
    }
}

extension PriceRange {
    init(_ dict: [String: Any]) {
        self.from = dict["from"] as? String
        self.to = dict["to"] as? String
    }
}
```

## Limitations

The limitations of Codable come about if you have a JSON document that holds an array of arbitrary types, because Codable only works automatically if the array contains a list of identical types, or a single unique type. I'll show how to work around this later using a combination of JSON Serializable and Codable together.

## Hybrid

Take this simplified example of a content managed page layout JSON data structure:

```json
[
   {
      "contentType": "carousel",
      "cards": [
         {
            "title": "Awesome title",
            "body": "Some interesting tagline",
            "image": "https://google.com/images?src=peanuts.jpg"
         },
         {
            "title": "Awesome title2",
            "body": "Some interesting tagline",
            "image": "https://google.com/images?src=peanuts.jpg"
         },
         {
            "title": "Awesome title3",
            "body": "Some interesting tagline",
            "image": "https://google.com/images?src=peanuts.jpg"
         }
      ]
   },
   {
      "contentType": "simpleBanner",
      "title": "Awesome title",
      "body": "Some interesting tagline"
   },
   {
      "contentType": "recentlyViewed",
      "title": "Awesome title",
      "products": [
         {
            "id": "9823475",
            "title": "76432: Lego Ultimate Batmobile",
            "price": "£199.00"
         }
      ]
   }
]
```

The above is an array of "any" type. So you cannot parse this using Codable. You can however very easily decode this to an array of generic dictionaries using JSON Serializable and then interrogate the key/value pairs to read the data.

There is a small trick in the way the above data was created. Every single dictionary contains a field called *contentType*. This allows us to process the JSON and understand what data each child dictionary contains.

To process the above assuming the above is stored in a string called *complexJSON* you can do:

```swift
guard let jsonData = complexJSON.data(using: .utf8) else {
    throw InvalidJson(json: complexJSON)
}

guard let array = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] else {
    throw InvalidJson(json: String(data: jsonData, encoding: .utf8) ?? "Invalid Data")
}
```

Once the data is in an array you can iterate over the dictionaries inside it and use the common *contentType* field to understand what type of data each dictionary contains.

```swift
for dict in array {
    // Here we're choosing to continue processing each dictionary using 'continue' simply throw an error if you would prefer to simply exit early and fail the entire process
    
    guard let contentTypeValue = dict["contentType"] as? String, let contentType = ContentType(rawValue: contentTypeValue) else { continue }
    
}
```

In the above example we are converting the *contentTypeValue* which is a string to an enum, but depending on your preference if you don't need it later on, you could process it as a string. There is better compiler type checking and less possibility for errors if you convert it to an enum.

Now that you have a way to know exactly what data structure an individual dictionary contains, you can choose which of two methods you would like to use in order to process your JSON data.

Option 1: you can use the init with dictionary solution.
Option 2: you can convert each dictionary back into JSON data and then use Codable to decode it.

I show examples of both these options in the *ComplexDataTests.swift* file.

The Codable data structure is nice and clean and looks like this:

```swift
public enum ContentType: String, Codable {
    case carousel
    case simpleBanner
    case recentlyViewed
}

protocol Component {
    var contentType: ContentType { get }
}

public struct Carousel: Codable, Component {
    let contentType: ContentType
    let cards: [CarouselCard]
}

public struct CarouselCard: Codable {
    let title: String
    let body: String
    let image: String
}

public struct SimpleBanner: Codable, Component {
    let contentType: ContentType
    let title: String
    let body: String
}

public struct RecentlyViewed: Codable, Component {
    let contentType: ContentType
    let title: String
    let products: [Product]
}

public struct Product: Codable {
    let id: String
    let title: String
    let price: String
}
```

In order to extend the above to include an init with dictionary initialiser it requires this additional code: 

```swift
public extension Carousel {
    init(_ dict: [String: Any], contentType: ContentType) throws {
        self.contentType = contentType
        let cardsDict: [[String: Any]] = try dict.value("cards")
        var cards = [CarouselCard]()
        
        for cardDict in cardsDict {
            let card = try CarouselCard(cardDict)
            cards.append(card)
        }
        
        self.cards = cards
    }
}

public extension CarouselCard {
    init(_ dict: [String: Any]) throws {
        self.title = try dict.value("title")
        self.body = try dict.value("body")
        self.image = try dict.value("image")
    }
}

public extension SimpleBanner {
    init(_ dict: [String: Any], contentType: ContentType) throws {
        self.contentType = contentType
        self.title = try dict.value("title")
        self.body = try dict.value("body")
    }
}

public extension RecentlyViewed {
    init(_ dict: [String: Any], contentType: ContentType) throws {
        self.contentType = contentType
        self.title = try dict.value("title")
        let productDicts: [[String: Any]] = try dict.value("products")
        var products = [Product]()
        
        for productDict in productDicts {
            let product = try Product(productDict)
            products.append(product)
        }
        
        self.products = products
    }
}

public extension Product {
    init(_ dict: [String: Any]) throws {
        self.id = try dict.value("id")
        self.title = try dict.value("title")
        self.price = try dict.value("price")
    }
}
```

If you look at the difference between the two sets of tests for both techniques, you will see that they both look very similar, and at first glance might not spot the differences. But as you can see, not using Codable to parse the individual dictionaries adds an additional 100 lines of code, and these are very basic contrived objects. In real code, many of the components could have 20-30+ properties and subclasses.

## Particularly great use case for JSON Serializable

A particularly great use case that I saw the other day where JSON Serializable was used was where we wanted to append a large remote config file with data from a different source. We did not want to include the secondary data in the remote config because we wanted to synchronise that data across ALL versions of the app, and each config file is for a single app version only.

The remote config is several thousands of lines long, has 10's of sub objects, and would require loads of tests if it were encoded and decoded fully. All we wanted to do was insert an additional property into the root level of the JSON document on the fly.

The solution was to decode the remote config to a dictionary, and then insert a new key into the dictionary where the value contained the required data. The dictionary could then be encoded back into JSON data using JSON Serializable and passed on to the app.

## Summary

I hope that I have managed to clearly show a range of examples of how to use Codable and JSON Serializable. As you can probably tell, for nearly all cases you are better off using Codable because it requires far less code, however if you are faced with a particularly complex JSON model or some of the other use cases mentioned above then falling back on JSON Serializable is not as daunting as it might seem.
