import Combine
import MusicKit

@MainActor
final class SongManager: ObservableObject {
    @Published var savedSongs: MusicItemCollection<Song>?
    @Published var errorMessage: String?
    private let songRepository: SongRepositoryProtocol

    init() {
        songRepository = SongRepositoryImpl()
    }

    func getAllSongs(sortOrder: SortOrder = .alphabetical) async {
        do {
            let songs = try await songRepository.getAllSongs(sortOrder: sortOrder)
            if let songs {
                savedSongs = songs
            } else {
                errorMessage = "Data cannot be fetched"
            }
        } catch {
            errorMessage = "Request failed with error: \(error.localizedDescription)"
        }
    }

    func invalidateCache() {
        savedSongs = nil
    }
}
