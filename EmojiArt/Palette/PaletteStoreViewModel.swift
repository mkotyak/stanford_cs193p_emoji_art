import Foundation
import SwiftUI

class PaletteStoreViewModel: ObservableObject {
    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }

    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }

    let name: String

    init(name: String) {
        self.name = name
        restoreFromUserDefaults()

        if palettes.isEmpty {
            debugPrint("using built-in palettes")
            insertPalette(
                named: "Vehicles",
                emojis: "๐๐๐๐๐๐๐๐ป๐๐๐๐๐๐๐โ๏ธ๐ซ๐ฌ๐ฉ๐๐ธ๐ฒ๐๐ถโต๏ธ๐ค๐ฅ๐ณโด๐ข๐๐๐๐๐๐๐๐บ๐"
            )
            insertPalette(
                named: "Sports",
                emojis: "๐โพ๏ธ๐โฝ๏ธ๐พ๐๐ฅ๐โณ๏ธ๐ฅ๐ฅ๐โท๐ณ"
            )
            insertPalette(
                named: "Music",
                emojis: "๐ผ๐ค๐น๐ช๐ฅ๐บ๐ช๐ช๐ป"
            )
            insertPalette(
                named: "Animals",
                emojis: "๐ฅ๐ฃ๐๐๐๐๐๐๐ฆ๐๐๐๐๐๐ฆ๐ฆ๐ฆ๐ฆ๐ข๐๐ฆ๐ฆ๐ฆ๐๐๐ฆ๐ฆ๐ฆง๐ฆฃ๐๐ฆ๐ฆ๐ช๐ซ๐ฆ๐ฆ๐ฆฌ๐๐ฆ๐๐ฆ๐๐ฉ๐ฆฎ๐๐ฆค๐ฆข๐ฆฉ๐๐ฆ๐ฆจ๐ฆก๐ฆซ๐ฆฆ๐ฆฅ๐ฟ๐ฆ"
            )
            insertPalette(
                named: "Animal Faces",
                emojis: "๐ต๐๐๐๐ถ๐ฑ๐ญ๐น๐ฐ๐ฆ๐ป๐ผ๐ปโโ๏ธ๐จ๐ฏ๐ฆ๐ฎ๐ท๐ธ๐ฒ"
            )
            insertPalette(
                named: "Flora",
                emojis: "๐ฒ๐ด๐ฟโ๏ธ๐๐๐๐พ๐๐ท๐น๐ฅ๐บ๐ธ๐ผ๐ป"
            )
            insertPalette(
                named: "Weather",
                emojis: "โ๏ธ๐คโ๏ธ๐ฅโ๏ธ๐ฆ๐งโ๐ฉ๐จโ๏ธ๐จโ๏ธ๐ง๐ฆ๐โ๏ธ๐ซ๐ช"
            )
            insertPalette(
                named: "COVID",
                emojis: "๐๐ฆ ๐ท๐คง๐ค"
            )
            insertPalette(
                named: "Faces",
                emojis: "๐๐๐๐๐๐๐๐คฃ๐ฅฒโบ๏ธ๐๐๐๐๐๐๐๐ฅฐ๐๐๐๐๐๐๐๐๐คช๐คจ๐ง๐ค๐๐ฅธ๐คฉ๐ฅณ๐๐๐๐๐๐โน๏ธ๐ฃ๐๐ซ๐ฉ๐ฅบ๐ข๐ญ๐ค๐ ๐ก๐คฏ๐ณ๐ฅถ๐ฅ๐๐ค๐ค๐คญ๐คซ๐คฅ๐ฌ๐๐ฏ๐ง๐ฅฑ๐ด๐คฎ๐ท๐คง๐ค๐ค "
            )
        }
        debugPrint("Successfully loaded palettes from userDefaults")
    }

    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }

    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData)
        {
            palettes = decodedPalettes
        }
    }

    // MARK: - Intents

    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }

    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }

    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let palette = Palette(name: name, emojis: emojis ?? "")
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}
