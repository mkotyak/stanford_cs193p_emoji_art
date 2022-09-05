import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var emojis: String
}
