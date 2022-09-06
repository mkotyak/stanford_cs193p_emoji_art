import SwiftUI

struct EmojiArtDocumentView: View {
    enum Constants {
        static let defaultEmojiFontSize: CGFloat = 40
        static let frameScale: CGFloat = 1.2
    }

    @State private var alertToShow: IdentifiableAlert?
    @State private var selectedEmojis: Set<EmojiArtModel.Emoji> = .init()

    @ObservedObject var documentViewModel: EmojiArtViewModel

    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser(emojiFontSize: Constants.defaultEmojiFontSize)
        }
    }

    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: documentViewModel.backgroudImage)
                        .scaleEffect(globalZoomScale)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size)
                    .exclusively(before: singleTapToResetSelection())
                )
                if documentViewModel.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(documentViewModel.emojis) { emoji in
                        ZStack {
                            Text(emoji.text)
                                .font(.system(size: fontSize(for: emoji)))
                                .gesture(dragSingle(emoji))
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 1)
                                .foregroundColor(.blue)
                                .frame(
                                    width: CGFloat(emoji.size) * Constants.frameScale,
                                    height: CGFloat(emoji.size) * Constants.frameScale
                                )
                                .opacity(selectedEmojis.contains(emoji) ? 1 : 0)
                        }
                        .scaleEffect(globalZoomScale)
                        .position(position(for: emoji, in: geometry))
                        .onTapGesture {
                            didSelect(emoji)
                        }
                        .onLongPressGesture(perform: {
                            unselect(emoji)
                            documentViewModel.remove(emoji)
                        })
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: documentViewModel.backgroundImageFetchStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
        }
    }

    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed: " + url.absoluteString, alert: {
            Alert(
                title: Text("Background Image Fetch"),
                message: Text("Chouldn't load image from \(url)"),
                dismissButton: .default(Text("Ok"))
            )
        })
    }

    private func unselect(_ emoji: EmojiArtModel.Emoji) {
        guard selectedEmojis.contains(emoji) else {
            return
        }

        selectedEmojis.remove(emoji)
        debugPrint("Selected emojis count after removing: \(selectedEmojis.count)")
    }

    private func didSelect(_ emoji: EmojiArtModel.Emoji) {
        debugPrint("\(emoji.text) emoji has been selected")

        guard !selectedEmojis.contains(emoji) else {
            selectedEmojis.remove(emoji)
            debugPrint("Selected emojis count unselection: \(selectedEmojis.count)")
            return
        }

        selectedEmojis.insert(emoji)
        debugPrint("Selected emojis count after insertion: \(selectedEmojis.count)")
    }

    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }

    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            documentViewModel.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    documentViewModel.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    documentViewModel.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: Constants.defaultEmojiFontSize / globalZoomScale
                    )
                }
            }
        }
        return found
    }

    // MARK: - Position

    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        debugPrint("EMOJI POSITION: ", emoji)
        debugPrint("GLOBAL ZOOM SCALE", globalZoomScale)
        return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }

    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / globalZoomScale,
            y: (location.y - panOffset.height - center.y) / globalZoomScale
        )
        debugPrint("LOCATION", location)
        return (Int(location.x), Int(location.y))
    }

    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        let point = CGPoint(
            x: center.x + CGFloat(location.x) * globalZoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * globalZoomScale + panOffset.height
        )
        debugPrint("CENTER:", center)
        debugPrint("POINT:", point)
        return point
    }

    // MARK: - Panning

    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero

    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * globalZoomScale
    }

    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                if selectedEmojis.isEmpty {
                    gesturePanOffset = latestDragGestureValue.translation / globalZoomScale
                } else {
                    selectedEmojis.forEach { emoji in
                        documentViewModel.moveEmoji(emoji, by: latestDragGestureValue.translation)
                    }
                }
            }
            .onEnded { finalDragGestureValue in
                if selectedEmojis.isEmpty {
                    steadyStatePanOffset =
                        steadyStatePanOffset + (finalDragGestureValue.translation / globalZoomScale)
                } else {
                    selectedEmojis.removeAll()
                }
            }
    }

    private func dragSingle(_ emoji: EmojiArtModel.Emoji) -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, _, _ in
                documentViewModel.moveEmoji(emoji, by: latestDragGestureValue.translation)
            }
    }

    // MARK: - Tapping

    private func singleTapToResetSelection() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedEmojis.removeAll()
            }
    }

    // MARK: - Zooming

    @State private var globalSteadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1

    private var globalZoomScale: CGFloat {
        globalSteadyStateZoomScale * gestureZoomScale
    }

    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                if selectedEmojis.isEmpty {
                    gestureZoomScale = latestGestureScale
                } else {
                    selectedEmojis.forEach { emoji in
                        documentViewModel.scaleEmoji(emoji, by: latestGestureScale)
                    }
                }
            }
            .onEnded { gestureScaleAtTheEnd in
                if selectedEmojis.isEmpty {
                    globalSteadyStateZoomScale *= gestureScaleAtTheEnd
                } else {
                    selectedEmojis.removeAll()
                }
            }
    }

    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(documentViewModel.backgroudImage, in: size)
                }
            }
    }

    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image,
           image.size.width > 0,
           image.size.height > 0,
           size.width > 0,
           size.height > 0
        {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            globalSteadyStateZoomScale = min(hZoom, vZoom)
        }
    }
}

// MARK: - Preview

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(documentViewModel: EmojiArtViewModel())
    }
}
