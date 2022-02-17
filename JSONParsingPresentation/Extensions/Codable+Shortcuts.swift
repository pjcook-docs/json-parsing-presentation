import Foundation

extension Decodable {
    static func decode(_ data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

extension Encodable {
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
