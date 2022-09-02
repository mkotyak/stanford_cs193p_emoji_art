import Foundation

struct Palette: Identifiable, Codable {
    var id = UUID()
    var name: String
    var emojis: String
}
