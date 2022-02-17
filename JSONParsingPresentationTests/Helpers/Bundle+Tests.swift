import Foundation
import JSONParsingPresentation

extension Bundle {
    func loadJson(_ filename: String) throws -> Data {
        guard let url = url(forResource: filename, withExtension: nil) else {
            throw InvalidFile(filename: filename)
        }
        return try Data(contentsOf: url)
    }
    
    class Bundler {}
    static var testBundle = Bundle(for: Bundler.self)
}
