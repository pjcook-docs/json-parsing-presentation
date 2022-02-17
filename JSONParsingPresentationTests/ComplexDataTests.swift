import XCTest
@testable import JSONParsingPresentation

// So how can we convert the complex JSON document into an array of Components?
// We cannot directly use Codable or Decodable, because there isn't a consistent single object that can be used to decode all of the different types of component because they all have different data structures, so how?
// JSON Serialization doesn't care about the structure of the JSON, only that the JSON is valid. So what we can do is use JSON Serialization to decode our JSON to an array of dictionaries. Then we can loop over the dictionaries 1 at a time and process them using either of the techniques that we previously used Codable or by passing the dictionary to an initialiser.

class ComplexDataTests: XCTestCase {
    func test_decodeComplexJSON_codable() throws {
        let jsonData = try Bundle.testBundle.loadJson("ComplexJson.json")
        let array = try jsonData.jsonToArray()
        var components = [Component]()
        for dict in array {
            // Here we're choosing to continue processing each dictionary using 'continue' simply throw an error if you would prefer to simply exit early and fail the entire process
            guard let contentTypeValue = dict["contentType"] as? String, let contentType = ContentType(rawValue: contentTypeValue) else { continue }
            
            let data = try dict.toJsonData()
            
            // Catch the errors if you want to ignore them and continue processing the rest of the document
            switch contentType {
            case .carousel:
                let component = try Carousel.decode(data)
                components.append(component)
                
            case .simpleBanner:
                let component = try SimpleBanner.decode(data)
                components.append(component)
                
            case .recentlyViewed:
                let component = try RecentlyViewed.decode(data)
                components.append(component)
            }
        }
        
        XCTAssertEqual(3, components.count)
    }
    
    func test_decodeComplexJSON_serialisable() throws {
        let jsonData = try Bundle.testBundle.loadJson("ComplexJson.json")
        let array = try jsonData.jsonToArray()
        var components = [Component]()
        for dict in array {
            // Here we're choosing to continue processing each dictionary using 'continue' simply throw an error if you would prefer to simply exit early and fail the entire process
            guard let contentTypeValue = dict["contentType"] as? String, let contentType = ContentType(rawValue: contentTypeValue) else { continue }
                        
            // Catch the errors if you want to ignore them and continue processing the rest of the document
            switch contentType {
            case .carousel:
                let component = try Carousel(dict, contentType: contentType)
                components.append(component)
                
            case .simpleBanner:
                let component = try SimpleBanner(dict, contentType: contentType)
                components.append(component)
                
            case .recentlyViewed:
                let component = try RecentlyViewed(dict, contentType: contentType)
                components.append(component)
            }
        }
        
        XCTAssertEqual(3, components.count)
    }

}
