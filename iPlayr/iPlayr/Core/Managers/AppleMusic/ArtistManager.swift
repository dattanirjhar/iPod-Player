import Combine
import MusicKit

@MainActor
final class ArtistManager: ObservableObject {
    @Published var savedArtists: MusicItemCollection<Artist>?
    @Published var artistAlbums: MusicItemCollection<Album>?
    @Published var errorMessage: String?
    private let artistRepository: ArtistRepositoryProtocol

    init() {
        artistRepository = ArtistRepositoryImpl()
    }

    func getCurrentUserArtists(sortOrder: SortOrder = .alphabetical) async {
        do {
            let artists = try await artistRepository.getCurrentUserArtists(sortOrder: sortOrder)
            if let artists {
                savedArtists = artists
            } else {
                errorMessage = "Data cannot be fetched"
            }
        } catch {
            errorMessage = "Request failed with error: \(error.localizedDescription)"
        }
    }

    func getArtistAlbums(artistName: String) async {
        do {
            let albums = try await artistRepository.getArtistAlbums(id: artistName)
            artistAlbums = albums ?? []
        } catch {
            errorMessage = "Request failed with error: \(error.localizedDescription)"
        }
    }

    func invalidateCache() {
        savedArtists = nil
    }
}
