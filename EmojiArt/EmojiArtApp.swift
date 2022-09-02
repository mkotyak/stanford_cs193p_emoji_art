import SwiftUI

@main
struct EmojiArtApp: App {
    let documentViewModel = EmojiArtViewModel()
    let paletteStore = PaletteStoreViewModel(name: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(documentViewModel: documentViewModel)
        }
    }
}
