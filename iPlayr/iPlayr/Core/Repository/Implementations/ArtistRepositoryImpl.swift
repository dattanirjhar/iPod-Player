import MusicKit
import Foundation

@MainActor
final class ArtistRepositoryImpl: ArtistRepositoryProtocol {

    func getCurrentUserArtists(sortOrder: SortOrder) async throws -> MusicItemCollection<Artist>? {
        var request = MusicLibraryRequest<Artist>()
        switch sortOrder {
        case .alphabetical:
            request.sort(by: \.name, ascending: true)
        case .dateAdded:
            request.sort(by: \.libraryAddedDate, ascending: false)
        }
        let response = try await request.response()
        return response.items
    }

    func getArtistAlbums(id: String) async throws -> MusicItemCollection<Album>? {
        var request = MusicLibraryRequest<Album>()
        request.filter(matching: \.artistName, equalTo: id)
        let response = try await request.response()
        return response.items
    }
}
