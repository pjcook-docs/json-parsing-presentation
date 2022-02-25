import XCTest
@testable import JSONParsingPresentation

class DetailedSerializableTests: XCTestCase {
    let simpleJson = "{\"age\":35,\"name\":\"Roger\"}"
    let detailedJson = "{\"age\":35,\"favourite_color\":\"Red\",\"favourite_pet\":\"Garfield\",\"name\":\"Roger\"}"
    
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
        let output = String(data: jsonData, encoding: .utf8)
        let expected = "{\"age\":35,\"favourite_color\":null,\"favourite_pet\":null,\"name\":\"Roger\"}"
        XCTAssertEqual(expected, output)
    }
    
    func testObject_toFullJSON() throws {
        let info = DetailedInfo(name: "Roger", age: 35, pet: "Garfield", color: "Red")
        let jsonData = try info.dictionary.toJsonData()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertEqual(detailedJson, output)
    }
}
