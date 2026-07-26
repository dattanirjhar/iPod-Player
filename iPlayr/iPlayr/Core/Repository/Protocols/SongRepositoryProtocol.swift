import MusicKit

@MainActor
protocol SongRepositoryProtocol: AnyObject {
    func getAllSongs(sortOrder: SortOrder) async throws -> MusicItemCollection<Song>?
}
