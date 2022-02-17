import Foundation

public struct InvalidProperty: Error {
    public let name: String
}

public struct InvalidJson: Error {
    public let json: String
}

public struct InvalidFile: Error {
    public let filename: String
    
    public init(filename: String) {
        self.filename = filename
    }
}
