import MusicKit
import Foundation

@MainActor
final class AlbumRepositoryImpl: AlbumRepositoryProtocol {
    
    func getAlbumTracks(id: String) async throws -> MusicItemCollection<Track>? {
        guard let album = try await fetchTracks(id: id)?.with(.tracks) else {
            throw NSError(domain: "MusicKitPlaylist", code: 2, userInfo: [NSLocalizedDescriptionKey: "Album not found."])
        }
        return album.tracks
    }
    
    func getCurrentUserSavedAlbums(sortOrder: SortOrder) async throws -> MusicItemCollection<Album>? {
        var request = MusicLibraryRequest<Album>()
        switch sortOrder {
        case .alphabetical:
            request.sort(by: \.title, ascending: true)
        case .dateAdded:
            request.sort(by: \.libraryAddedDate, ascending: false)
        }
        let response = try await request.response()
        return response.items
    }
    
    private func fetchTracks(id: String) async throws -> Album? {
        var request = MusicLibraryRequest<Album>()
        request.filter(matching: \.id, equalTo: MusicItemID(id))
        let response = try await request.response()
        return response.items.first
    }
}
