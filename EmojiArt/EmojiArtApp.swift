//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Maria Kotyak on 25.08.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let documentViewModel = EmojiArtViewModel()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(documentViewModel: documentViewModel)
        }
    }
}
