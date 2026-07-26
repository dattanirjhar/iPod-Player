import MusicKit
import Foundation

@MainActor
final class SongRepositoryImpl: SongRepositoryProtocol {

    func getAllSongs(sortOrder: SortOrder) async throws -> MusicItemCollection<Song>? {
        var request = MusicLibraryRequest<Song>()
        switch sortOrder {
        case .alphabetical:
            request.sort(by: \.title, ascending: true)
        case .dateAdded:
            request.sort(by: \.libraryAddedDate, ascending: false)
        }
        let response = try await request.response()
        return response.items
    }
}
