import Foundation
import SwiftUI

class EmojiArtViewModel: ObservableObject {
    private enum Autosave {
        static let filename = "Autoaved.emojiart"
        
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
            
            return documentDirectory?.appendingPathComponent(filename)
        }
        
        static let coalesingInterval = 5.0
    }
    
    @Published private(set) var emojiArtModel: EmojiArtModel {
        didSet {
            sceduleAutosave()
            if emojiArtModel.background != oldValue.background {
                fetchBackgrounfImageDataIfNecessary()
            }
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArtModel = try? EmojiArtModel(url: url) {
            emojiArtModel = autosavedEmojiArtModel
            fetchBackgrounfImageDataIfNecessary()
        } else {
            emojiArtModel = EmojiArtModel()
        }
    }
    
    @Published var backgroudImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArtModel.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArtModel.background
    }
    
    private var autosaveTimer: Timer?
    
    private func sceduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(
            withTimeInterval: Autosave.coalesingInterval,
            repeats: false
        ) { _ in
            self.autosave()
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArtModel.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch {
            print("\(thisFunction) error = \(error)")
        }
    }
    
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
        guard let index = emojiArtModel.emojis.index(matching: emoji) else {
            return
        }
        
        debugPrint("EMOJI IN MOOVE: ", emoji.x, emoji.y, offset)
        
        emojiArtModel.emojis[index].x = emoji.x + Int(offset.width)
        emojiArtModel.emojis[index].y = emoji.y + Int(offset.height)
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        guard let index = emojiArtModel.emojis.index(matching: emoji) else {
            return
        }
        
        debugPrint("EMOJI SCALE: ", emoji.size, scale)
        
        emojiArtModel.emojis[index].size = Int(
            (CGFloat(emoji.size) * scale).rounded(.toNearestOrAwayFromZero)
        )
    }
    
    func remove(_ emoji: EmojiArtModel.Emoji) {
        emojiArtModel.remove(emoji)
    }
}
