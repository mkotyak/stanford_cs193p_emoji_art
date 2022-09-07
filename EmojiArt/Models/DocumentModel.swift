import Foundation

struct DocumentModel: Codable {
    
    struct Emoji: Identifiable, Hashable, Codable {
        var id = UUID()
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    var background: Background = .blank
    var emojis = [Emoji]()
    
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(DocumentModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try DocumentModel(json: data)
    }
    
    init() {}
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        emojis.append(
            Emoji(
                text: text,
                x: location.x,
                y: location.y,
                size: size
            )
        )
    }
    
    mutating func remove(_ emoji: DocumentModel.Emoji) {
        emojis.remove(emoji)
    }
}
