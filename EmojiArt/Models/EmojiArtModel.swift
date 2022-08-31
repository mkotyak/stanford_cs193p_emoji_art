import Foundation

struct EmojiArtModel {
    struct Emoji: Identifiable, Hashable {
        let id = UUID()
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
//        var originalSize: Int
//        var scale: Float = 1
        
        fileprivate init(text: String, x: Int, y: Int, size: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
        
//        var size: Int {
//            Int(Float(originalSize) * scale)
//        }
    }
    
    var background: Background = .blank
    var emojis = [Emoji]()
    
    init() {}
    
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
    
    mutating func remove(_ emoji: EmojiArtModel.Emoji) {
        emojis.remove(emoji)
    }
}
