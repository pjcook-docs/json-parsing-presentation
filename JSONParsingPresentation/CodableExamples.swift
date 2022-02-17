import Foundation

// MARK: - simple example

public struct Info: Codable {
    public let name: String
}

// MARK: - slightly more complex example

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

// MARK: - hybrid example

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
