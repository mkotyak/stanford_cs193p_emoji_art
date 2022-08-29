import Foundation
import SwiftUI

class EmojiArtViewModel: ObservableObject {
    @Published private(set) var emojiArtModel: EmojiArtModel {
        didSet {
            if emojiArtModel.background != oldValue.background {
                fetchBackgrounfImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArtModel = EmojiArtModel()
//        emojiArtModel.addEmoji("🍟", at: (-200, -100), size: 60)
//        emojiArtModel.addEmoji("🙁", at: (50, 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArtModel.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArtModel.background
    }
    
    @Published var backgroudImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    private func fetchBackgrounfImageDataIfNecessary() {
        backgroudImage = nil
        
        switch emojiArtModel.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                
                DispatchQueue.main.async { [weak self] in
                    guard self?.emojiArtModel.background == EmojiArtModel.Background.url(url) else {
                        return
                    }
                    
                    self?.backgroundImageFetchStatus = .idle
                    if imageData != nil {
                        self?.backgroudImage = UIImage(data: imageData!)
                    }
                }
            }
        case .imageData(let data):
            backgroudImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArtModel.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArtModel.addEmoji(emoji, at: location, size: Int(size))
        print("\(emoji) has been added to \(location.x) : \(location.y) position with \(size) size")
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
