import Combine
import MusicKit

@MainActor
final class AlbumManager: ObservableObject {
    @Published var savedAlbums: MusicItemCollection<Album>?
    @Published var savedAlbumsTracks: MusicItemCollection<Track>?
    @Published var errorMessage: String?
    private let albumRepository: AlbumRepositoryProtocol
    
    init() {
        albumRepository = AlbumRepositoryImpl()
    }
    
    func getAlbumTracks(id: String) async {
        do {
            let tracks = try await albumRepository.getAlbumTracks(id: id)
            savedAlbumsTracks = tracks ?? []
        } catch {
            errorMessage = "Request failed with error: \(error.localizedDescription)"
        }
    }

    func getCurrentUserSavedAlbums(sortOrder: SortOrder = .alphabetical) async {
        do {
            let albums = try await albumRepository.getCurrentUserSavedAlbums(sortOrder: sortOrder)
            if let albums {
                savedAlbums = albums
            } else {
                errorMessage = "Data cannot be fetched"
            }
        } catch {
            errorMessage = "Request failed with error: \(error.localizedDescription)"
        }
    }

    func invalidateCache() {
        savedAlbums = nil
    }
}
