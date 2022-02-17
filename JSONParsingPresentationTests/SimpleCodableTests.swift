import XCTest
@testable import JSONParsingPresentation

class SimpleCodableTests: XCTestCase {
    func testJSON_toObject() throws {
        let jsonData = try "{\"name\":\"Roger\"}".toJsonData()
        let info = try Info.decode(jsonData)
        XCTAssertEqual("Roger", info.name)
    }
    
    func testJSON_toObject_invalidJSON() throws {
        let jsonData = try "{\"na me\":\"Roger\"}".toJsonData()
        XCTAssertThrowsError(try Info.decode(jsonData), "Failed") { error in
            XCTAssertTrue(error is Swift.DecodingError)
        }
    }
    
    func testObject_toJSON() throws {
        let expected = "{\"name\":\"Roger\"}"
        let info = Info(name: "Roger")
        let jsonData = try info.encode()
        let output = String(data: jsonData, encoding: .utf8)
        XCTAssertEqual(expected, output)
    }
}
