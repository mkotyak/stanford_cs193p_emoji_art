import Foundation
import SwiftUI

class DocumentViewModel: ObservableObject {
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
    
    @Published private(set) var documentModel: DocumentModel {
        didSet {
            sceduleAutosave()
            if documentModel.background != oldValue.background {
                fetchBackgrounfImageDataIfNecessary()
            }
        }
    }
    
    private var autosaveTimer: Timer?
    
    @Published var backgroudImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    var emojis: [DocumentModel.Emoji] {
        documentModel.emojis
    }
    
    var background: DocumentModel.Background {
        documentModel.background
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArtModel = try? DocumentModel(url: url) {
            documentModel = autosavedEmojiArtModel
            fetchBackgrounfImageDataIfNecessary()
        } else {
            documentModel = DocumentModel()
        }
    }
    
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
            let data: Data = try documentModel.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    private func fetchBackgrounfImageDataIfNecessary() {
        backgroudImage = nil
        
        switch documentModel.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                
                DispatchQueue.main.async { [weak self] in
                    guard self?.documentModel.background == DocumentModel.Background.url(url) else {
                        return
                    }
                    
                    self?.backgroundImageFetchStatus = .idle
                    if imageData != nil {
                        self?.backgroudImage = UIImage(data: imageData!)
                    }
                    if self?.backgroudImage == nil {
                        self?.backgroundImageFetchStatus = .failed(url)
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
    
    func setBackground(_ background: DocumentModel.Background) {
        documentModel.background = background
        print("background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        documentModel.addEmoji(emoji, at: location, size: Int(size))
        print("\(emoji) has been added to \(location.x) : \(location.y) position with \(size) size")
    }
    
    func moveEmoji(_ emoji: DocumentModel.Emoji, by offset: CGSize) {
        guard let index = documentModel.emojis.index(matching: emoji) else {
            return
        }
        
        debugPrint("EMOJI IN MOOVE: ", emoji.x, emoji.y, offset)
        
        documentModel.emojis[index].x = emoji.x + Int(offset.width)
        documentModel.emojis[index].y = emoji.y + Int(offset.height)
    }
    
    func scaleEmoji(_ emoji: DocumentModel.Emoji, by scale: CGFloat) {
        guard let index = documentModel.emojis.index(matching: emoji) else {
            return
        }
        
        debugPrint("EMOJI SCALE: ", emoji.size, scale)
        
        documentModel.emojis[index].size = Int(
            (CGFloat(emoji.size) * scale).rounded(.toNearestOrAwayFromZero)
        )
    }
    
    func remove(_ emoji: DocumentModel.Emoji) {
        documentModel.remove(emoji)
    }
}
