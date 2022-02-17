import Foundation

extension Dictionary where Key == String, Value == Any {
    func value(_ forKey: String) throws -> String {
        guard let value = self[forKey] as? String else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
    
    func value(_ forKey: String) throws -> Int {
        guard let value = self[forKey] as? Int else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
    
    func value(_ forKey: String) throws -> [String: Any] {
        guard let value = self[forKey] as? [String: Any] else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
    
    func value(_ forKey: String) throws -> [[String: Any]] {
        guard let value = self[forKey] as? [[String: Any]] else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
    
    func value(_ forKey: String) throws -> Bool {
        guard let value = self[forKey] as? Bool else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
    
    func value(_ forKey: String) throws -> Double {
        guard let value = self[forKey] as? Double else {
            throw InvalidProperty(name: forKey)
        }
        return value
    }
}

extension Dictionary where Key == String, Value == Any {
    func toJsonData() throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
    }
}
