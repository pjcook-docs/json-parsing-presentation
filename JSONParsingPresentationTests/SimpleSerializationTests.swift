import XCTest
@testable import JSONParsingPresentation

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
        let dict: [String: Any] = ["name": "Roger"]
        let jsonData = try dict.toJsonData()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
    
    func testDictionary_toObject_toJSON() throws {
        let expected = "{\"name\":\"Roger\"}"
        let dict: [String: Any] = ["name": "Roger"]
        let info = try Info(dict)
        let jsonData = try info.dictionary.toJsonData()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
    
    func testJSONToObject() throws {
        let jsonData = try "{\"name\":\"Roger\"}".toJsonData()
        let dict = try jsonData.jsonToDictionary()
        XCTAssertNotNil(dict)
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
        let jsonData = try info.dictionary.toJsonData()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(output)
        XCTAssertEqual(expected, output)
    }
}
