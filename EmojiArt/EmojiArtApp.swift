import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var documentViewModel = DocumentViewModel()
    @StateObject var paletteStore = PaletteStoreViewModel(name: "Default")
    
    var body: some Scene {
        WindowGroup {
            DocumentView(documentViewModel: documentViewModel)
                .environmentObject(paletteStore)
        }
    }
}
