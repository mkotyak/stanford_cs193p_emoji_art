import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var documentViewModel = EmojiArtViewModel()
    @StateObject var paletteStore = PaletteStoreViewModel(name: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(documentViewModel: documentViewModel)
                .environmentObject(paletteStore)
        }
    }
}
