import Foundation

extension Data {
    func jsonToDictionary() throws -> [String: Any] {
        guard let value = try JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? [String: Any] else {
            throw InvalidJson(json: String(data: self, encoding: .utf8) ?? "Invalid Data")
        }
        return value
    }
    
    func jsonToArray() throws -> [[String:Any]] {
        guard let value = try JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? [[String:Any]] else {
            throw InvalidJson(json: String(data: self, encoding: .utf8) ?? "Invalid Data")
        }
        return value
    }
}
