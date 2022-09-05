import Foundation

enum BackgroundImageFetchStatus: Equatable {
    case idle
    case fetching
    case failed(URL)
}
