import Foundation

// MARK: - Complex product example

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

// MARK: - Flattening data example

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
