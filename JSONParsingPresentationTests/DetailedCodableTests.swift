import XCTest
@testable import JSONParsingPresentation

class DetailedCodableTests: XCTestCase {
    let simpleJson = "{\"name\":\"Roger\",\"age\":35}"
    let detailedJson = "{\"name\":\"Roger\",\"age\":35,\"favourite_pet\":\"Garfield\",\"favourite_color\":\"Red\"}"
    
    func testJSON_toObject() throws {
        let jsonData = try simpleJson.toJsonData()
        let info = try DetailedInfo.decode(jsonData)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertNil(info.pet)
        XCTAssertNil(info.color)
    }
    
    func testJSON_toFullObject() throws {
        let jsonData = try detailedJson.toJsonData()
        let info = try DetailedInfo.decode(jsonData)
        XCTAssertEqual("Roger", info.name)
        XCTAssertEqual(35, info.age)
        XCTAssertEqual("Garfield", info.pet)
        XCTAssertEqual("Red", info.color)
    }
    
    func testObject_toJSON() throws {
        let info = DetailedInfo(name: "Roger", age: 35, pet: nil, color: nil)
        let jsonData = try info.encode()

        /* This won't work because the order of the fields that get output is not guaranteed */
        // let output = String(data: jsonData, encoding: .utf8)
        // XCTAssertEqual(expected, output)
        
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
        let jsonData = try info.encode()
        let expectedJSONData = try detailedJson.toJsonData()
        let info1 = try DetailedInfo.decode(jsonData)
        let info2 = try DetailedInfo.decode(expectedJSONData)
        XCTAssertEqual(info1.name, info2.name)
        XCTAssertEqual(info1.age, info2.age)
        XCTAssertEqual(info1.pet, info2.pet)
        XCTAssertEqual(info1.color, info2.color)
    }
}
