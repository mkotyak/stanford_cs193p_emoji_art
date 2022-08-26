import SwiftUI

struct EmojiArtDocumentView: View {
    enum Constants {
        static let defaultEmojiFontSize: CGFloat = 40
    }

    @ObservedObject var documentViewModel: EmojiArtViewModel
    let testEmojis: [String] = [
        "☃️", "🦀", "🐞", "🤣", "🤪",
        "🤖", "👩🏻‍🌾", "🐹", "🐜", "🦜",
        "🦫", "🌏", "🫔", "⚾️", "🎽",
        "🎮", "🚀", "🧿", "💔", "🏳️‍🌈",
        "♧", "🦄", "🦑", "🐍", "🐛",
        "🐊", "🦒", "🐕‍🦺", "🦥", "🌹",
        "🌝", "🌺", "🌟", "🌈", "☄️",
        "☀️", "🍋", "🥭", "🦴", "🍫"
    ]

    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }

    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.yellow
                ForEach(documentViewModel.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
            .onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
        }
    }

    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: Constants.defaultEmojiFontSize))
    }

    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }

    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
    }

    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int),
                                            in geometry: GeometryProxy) -> CGPoint
    {
        let center = geometry.frame(in: .local).center

        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }

    private func convertToEmojiCoordinate(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
        )

        return (Int(location.x), Int(location.y))
    }

    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        return providers.loadObjects(ofType: String.self) { string in
            if let emoji = string.first, emoji.isEmoji {
                documentViewModel.addEmoji(
                    String(emoji),
                    at: convertToEmojiCoordinate(location, in: geometry),
                    size: Constants.defaultEmojiFontSize
                )
            }
        }
    }
}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(documentViewModel: EmojiArtViewModel())
    }
}
