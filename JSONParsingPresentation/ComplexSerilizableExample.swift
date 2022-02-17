import Foundation

// MARK: - Complex product example

extension ComplexProduct {
    init(_ dict: [String: Any]) throws {
        self.id = try dict.value("productId")
        self.title = try dict.value("title")
        self.productDescription = try dict.value("description")
        self.price = try Price(dict.value("price"))
        self.size = dict["size"] as? ProductSize
        self.color = dict["color"] as? ProductColor
    }
}

extension Price {
    init(_ dict: [String: Any]) {
        self.was = PriceValue(dict["was"])
        self.then1 = PriceValue(dict["then1"])
        self.then2 = PriceValue(dict["then2"])
        self.now = PriceValue(dict["now"])
        self.uom = dict["uom"] as? String
        self.currency = dict["currency"] as? String
    }
}

extension PriceValue {
    init?(_ value: Any?) {
        guard let value = value else { return nil }
        if let value = value as? String {
            self = .single(value)
        } else if let value = value as? [String: Any] {
            self = .range(PriceRange(value))
        } else {
            return nil
        }
    }
}

extension PriceRange {
    init(_ dict: [String: Any]) {
        self.from = dict["from"] as? String
        self.to = dict["to"] as? String
    }
}

// MARK: - Flattening data example

extension Person {
    init(_ dict: [String: Any]) throws {
        self.name = try dict.value("name")
        
        let address: [String: Any] = try dict.value("address")
        self.address1 = try address.value("address1")
        self.address2 = address["address2"] as? String
        self.address3 = address["address3"] as? String
        self.zip = try address.value("zip")
        
        let personalDetails: [String: Any] = try dict.value("personalDetails")
        self.color = personalDetails["favourite_color"] as? String
        self.fruit = personalDetails["favourite_fruit"] as? String
    }
}
