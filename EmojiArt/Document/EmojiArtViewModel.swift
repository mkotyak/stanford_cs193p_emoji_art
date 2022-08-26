import Foundation
import SwiftUI

class EmojiArtViewModel: ObservableObject {
    @Published private(set) var emojiArtModel: EmojiArtModel
    
    init() {
        emojiArtModel = EmojiArtModel()
        emojiArtModel.addEmoji("🍟", at: (-200, -100), size: 80)
        emojiArtModel.addEmoji("🙁", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArtModel.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArtModel.background
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_background: EmojiArtModel.Background) {
        emojiArtModel.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArtModel.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArtModel.emojis.index(matching: emoji) {
            emojiArtModel.emojis[index].x += Int(offset.width)
            emojiArtModel.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArtModel.emojis.index(matching: emoji) {
            emojiArtModel.emojis[index].size = Int(
                (CGFloat(emojiArtModel.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero)
            )
        }
    }
}
