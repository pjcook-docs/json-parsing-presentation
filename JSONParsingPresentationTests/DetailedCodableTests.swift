import XCTest
@testable import JSONParsingPresentation

class DetailedCodableTests: XCTestCase {
    let simpleJson = "{\"name\":\"Roger\",\"age\":35}"
    let detailedJson = "{\"age\":35,\"favourite_color\":\"Red\",\"favourite_pet\":\"Garfield\",\"name\":\"Roger\"}"
    
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
        let output = String(data: jsonData, encoding: .utf8)
        let expected = "{\"age\":35,\"name\":\"Roger\"}"
        XCTAssertEqual(expected, output)
    }
    
    func testObject_toFullJSON() throws {
        let info = DetailedInfo(name: "Roger", age: 35, pet: "Garfield", color: "Red")
        let jsonData = try info.encode()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertEqual(detailedJson, output)
    }
}
