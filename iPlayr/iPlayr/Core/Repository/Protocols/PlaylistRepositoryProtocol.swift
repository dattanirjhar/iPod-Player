import MusicKit

@MainActor
protocol PlaylistRepositoryProtocol: AnyObject {
    func currentUserPlaylist(sortOrder: SortOrder) async throws -> MusicItemCollection<Playlist>?
    func getPlaylistTracks(id: String) async throws -> MusicItemCollection<Track>?
}
