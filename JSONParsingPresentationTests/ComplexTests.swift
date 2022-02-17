//
//  ComplexCodableTests.swift
//  JSONParsingPresentationTests
//
//  Created by PJ on 19/02/2022.
//

import XCTest
@testable import JSONParsingPresentation

class ComplexCodableTests: XCTestCase {
    // MARK: - Codable examples
    
    func test_codable_parseLego() throws {
        let jsonData = try Bundle.testBundle.loadJson("Lego.json")
        let product = try ComplexProduct.decode(jsonData)
        validateLego(product)
    }
    
    func test_codable_parseShoes() throws {
        let jsonData = try Bundle.testBundle.loadJson("Shoes.json")
        let product = try ComplexProduct.decode(jsonData)
        validateShoes(product)
    }
    
    func test_codable_person() throws {
        let jsonData = try Bundle.testBundle.loadJson("Person.json")
        let apiPerson = try API.Person.decode(jsonData)
        let person = Person(apiPerson)
        validatePerson(person)
    }
    
    // MARK: - JSON Serilizable examples
    
    func test_serializable_parseLego() throws {
        let jsonData = try Bundle.testBundle.loadJson("Lego.json")
        let dict = try jsonData.jsonToDictionary()
        let product = try ComplexProduct(dict)
        validateLego(product)
    }
    
    func test_serializable_parseShoes() throws {
        let jsonData = try Bundle.testBundle.loadJson("Shoes.json")
        let dict = try jsonData.jsonToDictionary()
        let product = try ComplexProduct(dict)
        validateShoes(product)
    }
    
    func test_serializable_person() throws {
        let jsonData = try Bundle.testBundle.loadJson("Person.json")
        let dict = try jsonData.jsonToDictionary()
        let person = try Person(dict)
        validatePerson(person)
    }
    
    // MARK: - Validation helpers
    
    func validateLego(_ product: ComplexProduct) {
        XCTAssertEqual("5941684", product.id)
        XCTAssertEqual("LEGO Creator Expert 10279 Volkswagen T2 Camper Van", product.title)
        XCTAssertEqual("Ideal for any car fanatics, life-long VW fans or as an additional present to their first car", product.productDescription)
        if case let .single(price) = product.price.now {
            XCTAssertEqual("111.99", price)
        } else {
            XCTFail("Invalid \"now\" price")
        }
        XCTAssertNil(product.size)
        XCTAssertNil(product.color)
    }

    func validateShoes(_ product: ComplexProduct) {
        XCTAssertEqual("4207194", product.id)
        XCTAssertEqual("Vans Ward Lace Up Trainers, Black", product.title)
        if case let .range(priceRange) = product.price.now {
            XCTAssertEqual("55.00", priceRange?.from)
            XCTAssertEqual("65.00", priceRange?.to)
        } else {
            XCTFail("Invalid \"now\" price")
        }
        XCTAssertEqual("8", product.size)
        XCTAssertNil(product.color)
    }
    
    func validatePerson(_ person: Person) {
        XCTAssertEqual("Tim Apple", person.name)
        XCTAssertEqual("1 Infinity Loop", person.address1)
        XCTAssertEqual("San Francisco", person.address2)
        XCTAssertEqual("California", person.address3)
        XCTAssertEqual(12345, person.zip)
        XCTAssertEqual("White", person.color)
        XCTAssertEqual("Apple", person.fruit)
    }
}
