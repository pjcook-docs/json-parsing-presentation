import Foundation

// MARK: - Simple example

extension Info {
    public init(_ dict: [String: Any]) throws {
        try self.init(name: dict.value("name"))
    }
    
    public var dictionary: [String: Any] {
        ["name": name]
    }
}

// MARK: - Slightly more complicated example

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

// MARK: - hybrid example

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
