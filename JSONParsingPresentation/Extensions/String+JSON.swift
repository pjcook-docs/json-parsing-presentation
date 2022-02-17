import Foundation

extension String {
    func toJsonData() throws -> Data {
        guard let jsonData = self.data(using: .utf8) else {
            throw InvalidJson(json: self)
        }
        return jsonData
    }
}
